class Settings < Grape::API
  resource :settings do
    desc 'ge base url'
    post 'base_url' do
      admin = Admin.first
      render :base_url => admin.base_url
    end
  end
end
