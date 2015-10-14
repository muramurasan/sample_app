require 'spec_helper'

describe "Static pages" do

  shared_examples "all static pages" do |heading, page_title|
    it { should have_content(heading) }
    it { should have_title(full_title(page_title)) }
  end

  subject { page }

  describe "Home page" do
    before { visit root_path }
    it_behaves_like "all static pages", 'Sample App', ''
    it { should_not have_title("| Home") }

    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      before(:each) do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

      it "should render the user's feed" do
        user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
      end

      describe "follower/following counts" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          other_user.follow!(user)
          visit root_path
        end

        it { should have_link("0 following", href: following_user_path(user)) }
        it { should have_link("1 followers", href: followers_user_path(user)) }
      end

      it "should render the user's feed count" do
        expect(page).to have_content("micropost".pluralize(user.feed.count))
      end
    end
  end

  describe "Help page" do
    before { visit help_path }
    it_behaves_like "all static pages", 'Help', 'Help'
  end

  describe "About page" do
    before { visit about_path }
    it_behaves_like "all static pages", 'About', 'About'
  end

  describe "Contact page" do
    before { visit contact_path }
    it_behaves_like "all static pages", 'Contact', 'Contact'
  end

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    expect(page).to have_title(full_title('About Us'))
    click_link "Help"
    expect(page).to have_title(full_title('Help'))
    click_link "Contact"
    expect(page).to have_title(full_title('Contact'))
    click_link "Home"
    click_link "Sign up now!"
    expect(page).to have_title(full_title('Sign up'))
    click_link "sample app"
    expect(page).to have_title(full_title(''))
  end

end
