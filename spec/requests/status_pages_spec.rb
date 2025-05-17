require 'rails_helper'

RSpec.describe "/status_pages", type: :request do
  let_it_be(:organization) { create(:organization) }
  let_it_be(:admin) { create(:user, :admin, organization: organization) }
  let_it_be(:member) { create(:user, :member, organization: organization) }

  let(:valid_attributes) {
    build(:status_page, organization: organization).attributes
  }

  let(:invalid_attributes) {
    build(:status_page, name: nil, organization: organization).attributes
  }

  describe "Admin" do
    before do
      sign_in admin
    end

    describe "GET /index" do
      it "renders a successful response" do
        StatusPage.create! valid_attributes
        get status_pages_url
        expect(response).to be_successful
      end
    end

    describe "GET /show" do
      it "renders a successful response" do
        status_page = StatusPage.create! valid_attributes
        get status_page_url(status_page)
        expect(response).to be_successful
      end
    end

    describe "GET /new" do
      it "renders a successful response" do
        get new_status_page_url
        expect(response).to be_successful
      end
    end

    describe "GET /edit" do
      it "renders a successful response" do
        status_page = StatusPage.create! valid_attributes
        get edit_status_page_url(status_page)
        expect(response).to be_successful
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new StatusPage" do
          expect {
            post status_pages_url, params: { status_page: valid_attributes }
          }.to change(StatusPage, :count).by(1)
        end

        it "redirects to the index status_page" do
          post status_pages_url, params: { status_page: valid_attributes }
          expect(response).to redirect_to(status_pages_url)
        end
      end

      context "with invalid parameters" do
        it "does not create a new StatusPage" do
          expect {
            post status_pages_url, params: { status_page: invalid_attributes }
          }.to change(StatusPage, :count).by(0)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post status_pages_url, params: { status_page: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        let(:new_attributes) {
          skip("Add a hash of attributes valid for your model")
        }

        it "updates the requested status_page" do
          status_page = StatusPage.create! valid_attributes
          patch status_page_url(status_page), params: { status_page: new_attributes }
          status_page.reload
          skip("Add assertions for updated state")
        end

        it "redirects to the status_page" do
          status_page = StatusPage.create! valid_attributes
          patch status_page_url(status_page), params: { status_page: new_attributes }
          status_page.reload
          expect(response).to redirect_to(status_page_url(status_page))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          status_page = StatusPage.create! valid_attributes
          patch status_page_url(status_page), params: { status_page: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "DELETE /destroy" do
      it "destroys the requested status_page" do
        status_page = StatusPage.create! valid_attributes
        expect {
          delete status_page_url(status_page)
        }.to change(StatusPage, :count).by(-1)
      end

      it "redirects to the status_pages list" do
        status_page = StatusPage.create! valid_attributes
        delete status_page_url(status_page)
        expect(response).to redirect_to(status_pages_url)
      end
    end
  end

  describe "Member" do
    before do
      sign_in member
    end

    describe "GET /index" do
      it "renders a successful response" do
        StatusPage.create! valid_attributes
        get status_pages_url
        expect(response).to be_successful
      end
    end

    describe "GET /show" do
      it "renders a successful response" do
        status_page = StatusPage.create! valid_attributes
        get status_page_url(status_page)
        expect(response).to redirect_to(root_url)
      end
    end

    describe "GET /new" do
      it "renders a successful response" do
        get new_status_page_url
        expect(response).to redirect_to(root_url)
      end
    end

    describe "GET /edit" do
      it "renders a successful response" do
        status_page = StatusPage.create! valid_attributes
        get edit_status_page_url(status_page)
        expect(response).to redirect_to(root_url)
      end
    end

    describe "POST /create" do
      context "with valid parameters" do
        it "creates a new StatusPage" do
          expect {
            post status_pages_url, params: { status_page: valid_attributes }
          }.to change(StatusPage, :count).by(0)
        end

        it "redirects to the index status_page" do
          post status_pages_url, params: { status_page: valid_attributes }
          expect(response).to redirect_to(root_url)
        end
      end

      context "with invalid parameters" do
        it "does not create a new StatusPage" do
          expect {
            post status_pages_url, params: { status_page: invalid_attributes }
          }.to change(StatusPage, :count).by(0)
        end

        it "renders a response with 422 status (i.e. to display the 'new' template)" do
          post status_pages_url, params: { status_page: invalid_attributes }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(root_url)
        end
      end
    end

    describe "PATCH /update" do
      context "with valid parameters" do
        let(:new_attributes) {
          skip("Add a hash of attributes valid for your model")
        }

        it "updates the requested status_page" do
          status_page = StatusPage.create! valid_attributes
          patch status_page_url(status_page), params: { status_page: new_attributes }
          status_page.reload
          skip("Add assertions for updated state")
        end

        it "redirects to the status_page" do
          status_page = StatusPage.create! valid_attributes
          patch status_page_url(status_page), params: { status_page: new_attributes }
          status_page.reload
          expect(response).to redirect_to(status_page_url(status_page))
        end
      end

      context "with invalid parameters" do
        it "renders a response with 422 status (i.e. to display the 'edit' template)" do
          status_page = StatusPage.create! valid_attributes
          patch status_page_url(status_page), params: { status_page: invalid_attributes }
          expect(response).to have_http_status(:found)
          expect(response).to redirect_to(root_url)
        end
      end
    end

    describe "DELETE /destroy" do
      it "destroys the requested status_page" do
        status_page = StatusPage.create! valid_attributes
        expect {
          delete status_page_url(status_page)
        }.to change(StatusPage, :count).by(0)
      end

      it "redirects to the status_pages list" do
        status_page = StatusPage.create! valid_attributes
        delete status_page_url(status_page)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_url)
      end
    end
  end
end
