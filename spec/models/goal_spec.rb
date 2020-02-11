require 'rails_helper'

RSpec.describe Goal, type: :model do
  let(:main_user) do 
    User.create!(
      username: "main_user", 
      password: "main_password", 
      up_votes_left: 10
    )
  end
  let(:category) { [Category.create!(name: "Work")] }
  subject!(:base_goal) do 
    Goal.new(title: "Be Better!", user: main_user, categories: category) 
  end
  describe "validations" do

    it { should validate_presence_of(:title) }
    it do  
      should validate_inclusion_of(:status)
        .in_array ["Not Started", "In Progress", "Complete"] 
    end
    it { should validate_uniqueness_of(:title).scoped_to(:user_id) }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:comments) }
    it { should have_many(:up_votes).dependent(:destroy) }
    it { should have_and_belong_to_many(:categories) }
  end

  describe "methods" do
    describe "::public Scope" do
      it "should return public goals" do
        public = Goal.create!(
          title: "Public",
          user: main_user,
          categories: category,
          public: true
        )
        expect(Goal.all.set_public).to include(public)
      end

      it "should not return private goals" do
        public = Goal.create!(
          title: "Public",
          user: main_user,
          categories: category,
          public: false
        )
        expect(Goal.all.set_public).not_to include(public)
      end
    end
    describe "::leaderboard" do
      let(:users) do 
        users = []
        10.times do |i| 
          users << User.create!(
            username: "user_#{i}", 
            password: "#{i}_password",
            up_votes_left: 10
          )
        end 
        users
    end
    let!(:upvoted_goals) do
      goals = []
      10.times do |i|
        goals << curr_goal = Goal.create!(
          title: "Goal #{i}", 
          user: users[i],
          public: true,
          categories: category
        )
        (i+1).times do |j| 
          UpVote.create!(
            goal: curr_goal,
            user: (i == j) ? main_user : users[j]
          )
        end
      end
      goals
    end

      it "only returns 10 goals" do
        expect(Goal.leaderboard.length).to be 10
      end

      it "returns goals in descending order of their cumulative received upvotes" do
        expect(Goal.leaderboard).to match_array(upvoted_goals.reverse)
      end

      it "includes up_votes_count as a property of the goal records" do
        expect(Goal.leaderboard.first.up_votes_count).to be 10
      end

    end
    describe "#get_up_vote(user)" do
      let(:user_2) { User.create!(username: "user_2", password: "password2") }
      
      it "returns nil when the goal does not have an existing upvote by the provided user" do
        expect(base_goal.get_up_vote(user_2)).to be nil
      end
      
      it "returns the upvote by the provided user if it exists" do
        user_2_goal = Goal.create!(title: "user_2_goal", user: user_2)
        main_user_upvote = UpVote.create!(user: main_user, goal: user_2_goal)
        expect(user_2_goal.get_up_vote(main_user)).to eq(main_user_upvote)
      end
    end
  end

end
