module API
  module V1
    # Brand controller for the rest API (V1).
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class BrandsController < ApplicationController
      # Hook who set brand object
      before_action :set_brand, only: [:show, :update, :destroy]

      # Check user right for avoid no-authorized access
      before_action :only_admin, only: [:create, :destroy, :update]

      # List all brands
      #
      def index
        # select only objects allowed by current user
        if @user.admin?
          @brands = Brand.all
        else
          @brands = @user.projects.flat_map(&:brand).uniq
        end

        # HACK need an AR array (even empty) for AMS
        @brands = Brand.none if @brands.length == 0

        respond_to do |format|
          format.json { render json: @brands, status: 200 }
        end
      end

      # Details about one brand
      def show
        respond_to do |format|
          format.json { render json: @brand, status: 200 }
        end
      end

      # Create a new brand
      #
      def create
        @brand = Brand.new(brand_params)

        respond_to do |format|
          if @brand.save
            format.json { render json: @brand, status: 200 }
          else
            format.json { render json: @brand.errors, status: :unprocessable_entity }
          end
        end
      end

      # Apply changes about one brand
      #
      def update
        respond_to do |format|
          if @brand.update(brand_params)
            format.json { render json: @brand, status: 200 }
          else
            format.json { render json: @brand.errors, status: :unprocessable_entity }
          end
        end
      end

      # Destroy one brand
      #
      def destroy
        @brand.destroy

        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private

      # Init current object
      #
      def set_brand
        @brand = Brand.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      #
      def brand_params
        params.require(:brand).permit(:name, :logo)
      end

    end
  end
end
