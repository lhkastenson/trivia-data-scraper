class BeforeAftersController < ApplicationController
  def index
    @before_afters = BeforeAfter.includes(:item_one, :item_two)

    if params[:status].present?
      @before_afters = @before_afters.where(status: params[:status])
    end

    if params[:min_rating].present?
      @before_afters = @before_afters.where("quality_rating >= ?", params[:min_rating])
    end

    if params[:format].present?
      @before_afters = @before_afters.where(format: params[:format])
    end

    sort_by = params[:sort_by] || "quality_rating"
    sort_dir = params[:sort_dir] || "desc"
    @before_afters = @before_afters.order("#{sort_by} #{sort_dir}")

    @before_afters = @before_afters.page(params[:page]).per(25)
  end

  def show
    @before_after = BeforeAfter.find(params[:id])
  end

  def update
    @before_after = BeforeAfter.find(params[:id])

    if @before_after.update(before_after_params)
      redirect_to before_afters_path, notice: "Updated!"
    else
      render :show
    end
  end

  def review
    @before_afters = BeforeAfter.includes(:item_one, :item_two)
      .where(status: "generated")
      .order(quality_rating: :desc)

    @current = @before_afters.first
    redirect_to before_afters_path, notice: "No more puzzles to review!" if @current.nil?
  end

  def quick_update
    @before_after = BeforeAfter.find(params[:id])

    if @before_after.update(before_after_params)
      next_puzzle = BeforeAfter.where(status: "generated")
        .where("id > ?", @before_after.id)
        .order(:id)
        .first

      if next_puzzle
        redirect_to review_before_afters_path
      else
        redirect_to review_before_afters_path, notice: "All done reviewing!"
      end
    else
      redirect_to review_before_afters_path, alert: "Update failed"
    end
  end

  private
  def before_after_params
    params.require(:before_after).permit(:status, :quality_rating)
  end
end
