Rails.application.routes.draw do

  get 'welcome/admin'

  get 'welcome/contactus'

  get 'index' => 'welcome#index'
  get 'about' => 'welcome#about'
  get 'contactus' => 'welcome#contactus'
  get 'main' => 'welcome#main'
  get 'signout' => 'welcome#index'
  get 'admin' => 'welcome#admin'
  get 'viewAllHotels' => 'welcome#viewAllHotels'

  get 'booknow' => 'welcome#booknow'

  post 'regpost' => 'welcome#regpost'
  post 'loginpost' => 'welcome#loginpost'
  post 'searchpost' => 'welcome#searchpost'

  root 'welcome#index'

end
