class GoalsController < ApplicationController
   def new
      @goal = Goal.new
      render :new
   end
end
