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
      def index
        # select only objects allowed by current user
        if @user.admin?
          @brands = Brand.all
        else
          projects = @user.projects
          if projects
            @brands = projects.flat_map(&:brand).uniq
          end
        end

        # Json output
        respond_to do |format|
            format.json { render json: @brands || [], status: 200 }
        end
      end

      # Details about one brand
      def show
        # Json output
        respond_to do |format|
          format.json { render json: @brand, status: 200 }
        end
      end

      # Create a new brand
      def create
        @brand = Brand.new(brand_params)

        # Json output
        respond_to do |format|
          if @brand.save
            format.json { render json: @brand, status: 200 }
          else
            format.json { render json: @brand.errors, status: :unprocessable_entity }
          end
        end
      end

      # Apply changes about one brand
      def update
        # Json output
        respond_to do |format|
          if @brand.update(brand_params)
            format.json { render json: @brand, status: 200 }
          else
            format.json { render json: @brand.errors, status: :unprocessable_entity }
          end
        end
      end

      # Destroy one brand
      def destroy
        @brand.destroy

        # Json output
        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_brand
          @brand = Brand.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def brand_params
          params.require(:brand).permit(:name, :logo)
        end
    end
  end
end
