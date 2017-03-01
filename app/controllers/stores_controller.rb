class StoresController < ApplicationController
  before_action :set_store, only: [:show, :edit, :update, :destroy]

  # GET /stores
  def index
  # @stores = Store.all
    #query = Store.select("sid, stname, staddr1, staddr2")
    #@stores_grid = initialize_grid(query)
   # @stores_grid = initialize_grid(Store.where(sid: 1).select("sid, stname, staddr1, staddr2"))
    @stores_grid = initialize_grid(Store.select("sid, stname, staddr1, staddr2, stcity"))
  end

  # GET /stores/1
  def show
  end

  # GET /stores/new
  def new
    @store = Store.new

  end

  # GET /stores/1/edit
  def edit
  end

  # POST /stores
  def create
    @store = Store.new(store_params)

    if @store.save
      redirect_to @store, notice: 'Store was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /stores/1
  def update
    if @store.update(store_params)
      redirect_to @store, notice: 'Store was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /stores/1
  def destroy
    @store.destroy
    redirect_to stores_url, notice: 'Store was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = Store.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def store_params
      params.require(:store).permit(:sid, :stname, :staddr1, :staddr2, :stcity)
    end
end
