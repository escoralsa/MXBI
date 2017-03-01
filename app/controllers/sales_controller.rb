class SalesController < ApplicationController
  before_action :set_sale, only: [:show, :edit, :update, :destroy]
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  # GET /sales
  # GET /sales.json
  def index
  #  @sales = Sale.all
    @sales1_grid = initialize_grid(Sale)
#    @sales_grid_test = initialize_grid(Sale.select("line", "qtysold").group(:line).sum('qtysold'))

    @sales_grid = initialize_grid(Sale.select("sid, date, line, part, sum(sell) as sell, sum(qtysold) as qtysold"),
                                 conditions: ['date >= ?', '2014-06-15'],
                                 order: :sell,
                                 order_direction: 'desc',
                                 group: 'line')


    @t=2
  end

  def linesTop
    @tienda = params[:tienda]
    @linea = params[:linea]
    @start_date = params[:start_date]
    @end_date= params[:end_date]
    @field = params[:field]


    if @start_date != nil
      if @linea != nil
        @nombre_linea = params[:linea]
        @ticketGroup = Sale.select("line", @field).where("date >= ? AND date <= ?", @start_date, @end_date).where(line: @nombre_linea).sum(@field, :group => 'sid')
        @e=3
        #@ticketGroup = Sale.select("line, qtysold").where("date >= ? AND date <= ?", @start_date, @end_date).where(line: @linea).where(sid: contador).sum(:qtysold, :group => 'sid')
      else
        #TOTALES POR LINEA
      #  @ticketGroup = Sale.select("line" + sum(@field)).group("line").where("date >= ? AND date <= ?", @start_date, @end_date).where(sid: @tienda)
        @ticketGroup = Sale.select("line", @field).where("date >= ? AND date <= ?", @start_date, @end_date).where(sid: @tienda).group(:line).sum(@field)
#Payment.group(:person_id).group(:product_id).sum(:amount)
      @R=1
       @titulo = " TIENDA " + @tienda +  " DEL "  + @start_date + " AL " + @end_date
      end


       @t=1
      @ticketGroup.each do |k, v|
        @Tot = {k => v.round(2)}

        if @hashTot != nil
          @hashTot.merge!(@Tot)
        else
          @hashTot = @Tot
        end
      end

      @r=2

      @sort = (@hashTot.sort_by { |line, total| total }.reverse)
      @chartValues = @sort.first(10).to_h
 @r=1

    else
      @sort = [0 => 'Sin Datos']
      @chartValues = {'0' => 0}
      @titulo = ""
    end

    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: "10 Lineas mas Vendidas")
      f.xAxis(categories: @chartValues.keys)
      f.series(name: "Unidades", yAxis: 0, data: @chartValues.values)
      f.yAxis [
                  {title: {text: "# Pizas en Miles", margin: 70} },
                  {title: {text: "# Pizas en Miles"}, opposite: true},
              ]

      f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical')
      f.chart({defaultSeriesType: "column"})
    end

    @chart_globals = LazyHighCharts::HighChartGlobals.new do |f|
      f.global(useUTC: false)
      f.chart(
          backgroundColor: {
              linearGradient: [0, 0, 500, 500],
              stops: [
                  [0, "rgb(255, 255, 255)"],
                  [1, "rgb(240, 240, 255)"]
              ]
          },
          borderWidth: 2,
          plotBackgroundColor: "rgba(255, 255, 255, .9)",
          plotShadow: true,
          plotBorderWidth: 1
      )
      f.lang(thousandsSep: ",")
      f.colors(["#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354"])
    end


    smart_listing_create :saleslinesTop, @sort, partial: "sales/listlinesTop"
  end
  def allStores

  @fin = Store.count(:all)

  @linea = params[:line]
  @start_date = params[:start_date]
  @end_date= params[:end_date]


  if @start_date != nil
    if @linea != nil
      @nombre_linea = params[:line]

      @titulo = " LINEA " + @linea +  " DEL "  + @start_date + " AL " + @end_date

      (0..@fin).each do |contador|
        puts "iteracion #{contador}"

        # @ticketGroup = TicketItem.filterData(@start_date, @end_date).select("line, qtysold").where(line: @linea).where(sid: contador).sum(:qtysold, :group => 'tkt.sid')

        @ticketGroup = Sale.select("line, qtysold").where("date >= ? AND date <= ?", @start_date, @end_date).where(line: @linea).where(sid: contador).sum(:qtysold, :group => 'sid')

        if @allStores != nil

          @r=3
          @allStores.merge!(@ticketGroup)
          @t=5
        else

          @allStores = @ticketGroup

          @g=4
        end
      end

      @sort = @allStores.sort_by { |line, total| total }.reverse

      @chartValues = @sort.first(10).to_h

      @total = 0
      @sort.each { |key, value| @total += value}

      @total = @total.to_s
      @e=4
    end
  else
    @titulo = " "
    @sort = ['Sin Datos']
    @chartValues = {'0' => 0}
  end

  @chart = LazyHighCharts::HighChart.new('column') do |f|

    f.title(text: @titulo)
    f.xAxis(categories: @chartValues.keys)
    f.series(name: "Unidades", yAxis: 0, data: @chartValues.values)
    f.yAxis [
                {title: {text: "# Pizas en Miles", margin: 70} },
                {title: {text: "# Pizas en Miles"}, opposite: true},
            ]

    ## or options for column
    f.options[:chart][:defaultSeriesType] = "column"
    f.plot_options({:column=>{:options3d=>  {
        enabled: true,
        alpha: 15,
        beta: 15,
        depth: 50,
        viewDistance: 25
    }}})
  end

  @chart_globals = LazyHighCharts::HighChartGlobals.new do |f|
    f.global(useUTC: false)
    f.chart(
        backgroundColor: {
            linearGradient: [0, 0, 500, 500],
            stops: [
                [0, "rgb(255, 255, 255)"],
                [1, "rgb(240, 240, 255)"]
            ]
        },
        borderWidth: 2,
        plotBackgroundColor: "rgba(255, 255, 255, .9)",
        plotShadow: true,
        plotBorderWidth: 1,
        plotOptions3d: {enabled: true, depth: 50},
    )
    f.lang(thousandsSep: ",")
    f.colors(["#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354"])
  end

  smart_listing_create :itemsLineAllStores, @sort, partial: "ticket_items/listAllStores"
  end


  def allStoresPart

    @fin = Store.count(:all)

    @linea = params[:line]
    @parte = params[:part]
    @start_date = params[:start_date]
    @end_date= params[:end_date]


    if @start_date != nil
      if @linea != nil
        @nombre_linea = params[:line]
        @nombre_parte = params[:part]

        @titulo = " LINEA " + @linea + " PARTE " + @parte + " DEL "  + @start_date + " AL " + @end_date

        (0..@fin).each do |contador|
          puts "iteracion #{contador}"

          #@ticketGroup = TicketItem.filterLinea(@start_date, @end_date).select("line, qtysold").where(line: @linea).where(part: @parte).where(sid: contador).sum(:qtysold, :group => 'tkt.sid')


          @ticketGroup = Sale.select("line, qtysold").where("date >= ? AND date <= ?", @start_date, @end_date).where(line: @linea).where(part: @parte).where(sid: contador).sum(:qtysold, :group => 'sid')

          if @allStores != nil
            @allStores.merge!(@ticketGroup)
          else
            @allStores = @ticketGroup
          end
        end

        @sort = @allStores.sort_by { |line, total| total }.reverse

        @total = 0
        @sort.each { |key, value| @total += value}

        @total = @total.to_s
        @e=4
      end
    else
      @titulo = " "
      @sort = ['Sin Datos']
    end
    smart_listing_create :itemsPartAllStores, @sort, partial: "ticket_items/listAllStoresPart"
  end


  def allYearLine


    @linea = params[:line]
    @tienda = params[:tienda]
    @year = params[:year]

    if @year != nil
      if @linea != nil
        (1..12).each do |contador|
          puts "iteracion #{contador}"

          days = Time.days_in_month(contador, @year).to_s

          @mes=Date::MONTHNAMES[contador]
          @g=2
          @start_date = @year + '-' + contador.to_s + '-' + '01'
          @end_date = @year + '-' + contador.to_s + '-' + days

          @fecha = Ticket.select('idate').where(sid: 1).group('idate')
          #@ticketGroup = TicketItem.filterLinea(@start_date, @end_date).select("line, qtysold").where(line: @linea).where(sid: @tienda).sum(:qtysold)

          @ticketGroup = Sale.select("line, qtysold").where("date >= ? AND date <= ?", @start_date, @end_date).where(line: @linea).where(sid: @tienda).sum(:qtysold)

          @groupMonth = {@mes => @ticketGroup}

          if @Month != nil
            @Month.merge!(@groupMonth)
          else
            @Month = @groupMonth
          end
        end

      end
    else
      @titulo = " "
      @Month = {'0' => 0}
    end

    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: @titulo)
      f.xAxis(categories: @Month.keys)
      f.series(name: "Unidades", yAxis: 0, data: @Month.values)
      f.yAxis [
                  {title: {text: "# Pizas en Miles", margin: 70} },
                  {title: {text: "# Pizas en Miles"}, opposite: true},
              ]

      f.legend(align: 'right', verticalAlign: 'top', y: 75, x: -50, layout: 'vertical')
      f.chart({defaultSeriesType: "column"})
    end

    @chart_globals = LazyHighCharts::HighChartGlobals.new do |f|
      f.global(useUTC: false)
      f.chart(
          backgroundColor: {
              linearGradient: [0, 0, 500, 500],
              stops: [
                  [0, "rgb(255, 255, 255)"],
                  [1, "rgb(240, 240, 255)"]
              ]
          },
          borderWidth: 2,
          plotBackgroundColor: "rgba(255, 255, 255, .9)",
          plotShadow: true,
          plotBorderWidth: 1
      )
      f.lang(thousandsSep: ",")
      f.colors(["#90ed7d", "#f7a35c", "#8085e9", "#f15c80", "#e4d354"])
    end
    smart_listing_create :itemsAllYearLine, @Month, partial: "sales/listAllYearLine"
  end


  # GET /sales/1
  # GET /sales/1.json
  def show
  end

  # GET /sales/new
  def new
    @sale = Sale.new
  end

  # GET /sales/1/edit
  def edit
  end

  # POST /sales
  # POST /sales.json
  def create
    @sale = Sale.new(sale_params)

    respond_to do |format|
      if @sale.save
        format.html { redirect_to @sale, notice: 'Sale was successfully created.' }
        format.json { render action: 'show', status: :created, location: @sale }
      else
        format.html { render action: 'new' }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sales/1
  # PATCH/PUT /sales/1.json
  def update
    respond_to do |format|
      if @sale.update(sale_params)
        format.html { redirect_to @sale, notice: 'Sale was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales/1
  # DELETE /sales/1.json
  def destroy
    @sale.destroy
    respond_to do |format|
      format.html { redirect_to sales_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sale
      @sale = Sale.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def sale_params
      params.require(:sale).permit(:id, :date, :sid, :line, :part, :sell, :qtysold)
    end
end
