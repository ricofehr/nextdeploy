# Endpoint class who joints framework and project with some extra field
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Uri < ActiveRecord::Base
  # An Heleer module contains IO functions
  include UrisHelper

  belongs_to :vm
  belongs_to :framework

  after_update :create_vhost
  after_update :refresh_vm
  before_create :check_hrefs
  after_create :create_vhost
  before_destroy :delete_vhost, prepend: true

  validates :absolute, presence: true, length: {maximum: 255}, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9\.-]+\z/ }
  validates :aliases, allow_blank: true, uniqueness: { case_sensitive: false }, format: { with: /\A[\ a-zA-Z0-9\.-]+\z/ }

  private

  # Add os_suffix for default hrefs (= project endpoint) on uri object
  #
  def check_hrefs
    if absolute.match(/^.*[0-9]$/)
      self.absolute = "#{absolute}#{Rails.application.config.os_suffix}"
    end

    unless aliases.nil? || aliases.empty?
      self.aliases = aliases.split(' ').map do |aliase|
        aliase.match(/^.*[0-9]$/) && aliase = "#{aliase}#{Rails.application.config.os_suffix}"
      end.join(' ')
    end
  end

  # Refresh vm hiera and puppet
  #
  def refresh_vm
    vm.generate_hiera
    vm.generate_host_all
    vm.puppet_refresh
  end
end
