# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'alerts', :to => 'alerts#index'

get 'notifications', :to => 'alerts#notifications'