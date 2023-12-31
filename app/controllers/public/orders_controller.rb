class Public::OrdersController < ApplicationController
  before_action :authenticate_member!, only: [:new, :confirm, :create, :index, :show, :complete]

  def new
  end

  def confirm
    @cart_items = CartItem.where(member_id: current_member.id)
    @shipping_fee = 800

    @selected_pay_method = params[:order][:pay_method]

    # 商品の合計額
    ary = []
    @cart_items.each do |cart_item|
      ary << cart_item.item.add_tax_price*cart_item.quantity
    end
    @cart_items_price = ary.sum

    @total_price = @shipping_fee + @cart_items_price

    @address_type = params[:order][:address_type]
    case @address_type
    when "member_address"
      @selected_address = current_member.post_code + " " + current_member.address + " " + current_member.family_name + current_member.first_name
    when "registered_address"
      unless params[:order][:registered_address_id] == ""
        selected = Address.find(params[:order][:registered_address_id])
        @selected_address = selected.post_code + " " + selected.address + " " + selected.name
      else
        flash.now[:notice] = "お届け先を選択してください"
        render :new
      end
    when "new_address"
      unless params[:order][:new_post_code] == "" && params[:order][:new_address] == "" && params[:order][:new_name] == ""
        @selected_address = params[:order][:new_post_code] + " " + params[:order][:new_address] + " " + params[:order][:new_name]
      else
        flash.now[:notice] = "お届け先を記入してください"
        render :new
      end
    end
  end

  def create
    @order = Order.new
    @order.member_id = current_member.id
    @order.shipping_fee = 800

    @cart_items = CartItem.where(member_id: current_member.id)
    ary = []
    @cart_items.each do |cart_item|
      ary << cart_item.item.add_tax_price*cart_item.quantity
    end
    @cart_items_price = ary.sum
    @order.total_price = @order.shipping_fee + @cart_items_price
    @order.pay_method = params[:order][:pay_method]
    @order.status = 0

    address_type = params[:order][:address_type]
    case address_type
    when "member_address"
      @order.post_code = current_member.post_code
      @order.address = current_member.address
      @order.name = current_member.family_name + current_member.first_name
    when "registered_address"
      Address.find(params[:order][:registered_address_id])
      selected = Address.find(params[:order][:registered_address_id])
      @order.post_code = selected.post_code
      @order.address = selected.address
      @order.name = selected.name
    when "new_address"
      @order.post_code = params[:order][:new_post_code]
      @order.address = params[:order][:new_address]
      @order.name = params[:order][:new_name]
    end

    if @order.save
      @cart_items.each do |cart_item|
      OrderDetail.create!(order_id: @order.id, item_id: cart_item.item.id, price: cart_item.item.add_tax_price, quantity: cart_item.quantity, making_status: 0)
      end
      @cart_items.destroy_all
      redirect_to complete_orders_path
    else
      flash.now[:notice] = "注文が確定できませんでした。もう一度やり直してください。"
      render :items
    end
  end


  def index
    @orders = Order.where(member_id: current_member.id).order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    @order = Order.find(params[:id])
    @order_details= OrderDetail.where(order_id: @order.id)
  end

  def complete
  end

end
