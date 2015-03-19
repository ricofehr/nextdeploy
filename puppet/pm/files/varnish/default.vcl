acl purge {
  "127.0.0.1";
}

#web1
backend default {
  .host = "127.0.0.1";
  .port = "8080";
  .connect_timeout = 600s;
  .first_byte_timeout = 600s;
  .between_bytes_timeout = 600s;
}

sub vcl_recv {
  // Rename the incoming XFF header to work around a Varnish bug.
  if (req.http.X-Forwarded-For) {
    // Append the client IP
    set req.http.X-Real-Forwarded-For = req.http.X-Forwarded-For+", "+req.http.Client_IP;
    unset req.http.X-Forwarded-For;
  }
  else {
    // Simply use the client IP
    set req.http.X-Real-Forwarded-For = req.http.Client_IP;
  }

  #set req.backend = default;

  # Si la requete est PURGE, on trie
  if (req.request == "PURGE") {
    if (!client.ip ~ purge) {
      error 405 "Not allowed.";
    }
    #Ajout de la commande de purge
    ban("req.url ~ "+req.url);
  }

  # Options de securite :
  # On accepte que les requetes GET POST et HEAD, le reste est jete
  
  if (req.request != "GET" &&
      req.request != "POST" &&
      req.request != "HEAD") {
        error 405 "Not allowed";
  }

  # Tout ce qui n'est pas GET ou HEAD ne sera pas mis en cache
  # On utilise la directive PASS et non PIPE
  if (req.request != "GET" &&
      req.request != "HEAD") {
        return (pass);
  }

  # On normalise les header de compression GZIP
  # A cause de IE et FF qui ne sont pas normalises
  if (req.http.Accept-Encoding) {
    if (req.http.Accept-Encoding ~ "gzip") {
      set req.http.Accept-Encoding = "gzip";
    }
    elsif (req.http.Accept-Encoding ~ "deflate") {
      set req.http.Accept-Encoding = "deflate";
    }
    else {
      # Algorithme de compression inconnu : on supprime
      unset req.http.Accept-Encoding;
    }
  }

  set req.grace = 30s;
  # Si requete Expect, on pipe sur le backend
  if (req.http.Expect) {
    return (pipe);
  }

  if(req.http.User-Agent ~ "^facebook" || req.http.User-Agent ~ "Firefox/6.0 Google \(\+https://developers") {
       return(pipe) ;
  }

  ###AUTH###

 ## Remove has_js and Google Analytics cookies.
  set req.http.Cookie = regsuball(req.http.Cookie, "(^|;[ \t\r\n\v\f]*)(__[a-z]+|has_js|NSC_[a-z0-9A-Z-]+)=[^;]*", "");
  ## Remove a “;” prefix, if present.
  set req.http.Cookie = regsub(req.http.Cookie, "^;[ \t\r\n\v\f]*", "");

  # Remove cookies and query string for real static files
  if (req.url ~ "^/[^?]+\.(jpeg|jpg|png|gif|ico|js|css|txt|gz|zip|lzma|bz2|tgz|tbz|flv|f4v|swf|html)(\?.*|)$") {
                unset req.http.cookie;
  }

  ## Remove empty cookies.
  if (req.http.Cookie ~ "^[ \t\r\n\v\f]*$") {
    unset req.http.Cookie;
  }
 
  ## Pass cron jobs and server-status
  if (req.url ~ "cron.php" ||
                        req.url ~ ".*/server-status$" ||
			req.url ~ ".*/nginx-status$" ||
                        req.url ~ "/_pm/" ||
			req.url ~ "/pminfo.php" ||
                        req.url ~ "/phpmyadmin/") {
  	if (client.ip == "127.0.0.1" || client.ip == "81.200.177.174" || client.ip == "81.200.176.17")
        {
                return(pass) ;
        }
  error 405 "Not allowed";
  }

  if (req.http.Authenticate || req.http.Cookie) {
        return(pass);
  }
        return(lookup);
}
# ================================
sub vcl_pipe {
#    # Note that only the first request to the backend will have
#    # X-Forwarded-For set.  If you use X-Forwarded-For and want to
#    # have it set for all requests, make sure to have:
#    # here.  It is not set by default as it might break some broken web
#    # applications, like IIS with NTLM authentication.
  set req.http.connection = "close";
  return (pipe);
}
# ================================
sub vcl_pass {
  # L'objet n'est pas en cache, donc on veut un fectch
  # complet et pas un 304
  # RFC2616 14.X
  unset req.http.If-Match;
  unset req.http.If-Modified-Since;
  unset req.http.If-None-Match;
  unset req.http.If-Range;
  unset req.http.If-Unmodified-Since;
  # On passe la requete.
  return (pass);
}

# ================================
sub vcl_hash {
  hash_data(req.url);

  if (req.http.host) {
    hash_data(req.http.host);
  } else {
    hash_data(server.ip);
  }

  return (hash);
}

# ================================
sub vcl_hit {
  # Si requete 'purge' on place le TTL a 0s
  if (req.request == "PURGE") {
          set obj.ttl = 0s;
          error 200 "Purged.";
  }

  # Si objet non cachable, on passe au backend
  if (obj.ttl == 0s) {
     return (pass);
  }

  # Finalement on delivre l'objet en cache
  return (deliver);
}


# ================================
sub vcl_miss {
  # L'objet n'est pas en cache, donc on veut un fectch
  # complet et pas un 304
  # RFC2616 14.X
  unset req.http.If-Match;
  unset req.http.If-Modified-Since;
  unset req.http.If-None-Match;
  unset req.http.If-Range;
  unset req.http.If-Unmodified-Since;
  # Si requete 'purge' et objet pas en cache, retour code 404
  if (req.request == "PURGE") {
    error 404 "Not in cache.";
  }
  # On va sur le backend
  return (fetch);
}

# ================================
sub vcl_fetch {
 set beresp.grace = 30s;

  # Si l'objet ne peut etre mis en cache
  # http code != 200, 203, 300, 301, 302, 404 ou 410
  # Util pour debug les politiques de caches
  if (beresp.ttl <= 0s || (beresp.status != 200 && beresp.status != 404)) {
     set beresp.http.X-Cacheable = "NO:Not Cacheable";
     set beresp.ttl = 120s;
     return(hit_for_pass);
  }
  elsif (beresp.http.Cache-Control ~ "private" ||
          beresp.http.Cache-Control ~ "no-cache" ||
          beresp.http.Cache-Control ~ "no-store") {
     set beresp.http.X-Cacheable = "NO:Cache-Control=private";
     return(hit_for_pass);
  }
  else {
    set beresp.http.X-Cacheable = "YES";
    if(beresp.status == 404)
    {
        set beresp.ttl = 10m;
    }
    else
    {
         set beresp.ttl = 24h;
    }
  }

  # on laisse drupal ou lighttpd définir la rétention
  # set obj.http.Cache-Control = "max-age=86400";
  # set obj.ttl=86400s;

        # Par defaut, on ajoute au cache
  return(deliver);
}

sub vcl_deliver {
  # On tag le temps du debug
  if (obj.hits > 0) {
     set resp.http.X-Cache = "HIT";
  } else {
     set resp.http.X-Cache = "MISS";
  }
  set resp.http.V-PM = "1";

  #On force le client à rafraichir tout de même
  if ( resp.http.Cache-control ~ "public|private" ) {
    unset resp.http.Etag;
    unset resp.http.Age;
    unset resp.http.Cache-Control;
    set resp.http.Cache-Control = "no-cache, no-store, max-age=0, must-revalidate";
  }

  #Lighttpd doesn't put any Cache-control policy, only max-age.
  if ( resp.http.Cache-Control ~ "^max-age=[0-9]+$" ) {
    set resp.http.Cache-Control = regsub( resp.http.Cache-Control, "^max-age=([0-9]+)$", "public, max-age=\1" );
  }

  # On delivre la reposne de la requete au client
  # On supprime les header trop indiscrets
  unset resp.http.Server;
  unset resp.http.X-Powered-By;
  unset resp.http.via;
  unset resp.http.X-Varnish;
  unset resp.http.Served-by;
  # On delivre au client
  return (deliver);
}

sub vcl_error {
if (obj.status == 401) {
  set obj.http.Content-Type = "text/html; charset=utf-8";
  set obj.http.WWW-Authenticate = "Basic realm=Secured";
  synthetic {"

 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
 "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">

 <HTML>
 <HEAD>
 <TITLE>Error</TITLE>
 <META HTTP-EQUIV='Content-Type' CONTENT='text/html;'>
 </HEAD>
 <BODY><H1>401 Unauthorized (varnish)</H1></BODY>
 </HTML>
 "};
  return (deliver);
}

return (deliver);
}
