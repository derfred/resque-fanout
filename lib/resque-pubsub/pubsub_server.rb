module Resque
  module PubsubServer

    VIEW_PATH = File.join(File.dirname(__FILE__), 'views')

    def self.registered(app)
      # index
      app.get "/pubsub/?" do
        @exchanges = Resque.exchanges
        @queues = Resque.queues
        erb(File.read(File.join(::Resque::PubsubServer::VIEW_PATH, "index.erb")))
      end

      # create new mapping
      app.post '/pubsub/?' do
        if valid_mapping? params
          Resque.subscribe params[:exchange], :queue => params[:queue], :class => params[:class]
          redirect u(:pubsub, "?notice=#{URI.escape 'Mapping created'}")
        else
          redirect u(:pubsub, "?error=#{URI.escape 'Invalid Mapping'}")
        end
      end

      # delete mapping
      app.post '/pubsub/:exchange/:queue/remove' do
        if valid_mapping? params
          Resque.unsubscribe params[:exchange], :queue => params[:queue]
          redirect u(:pubsub, "?notice=#{URI.escape 'Mapping removed'}")
        else
          redirect u(:pubsub, "?error=#{URI.escape 'Invalid Parameters'}")
        end
      end

      app.helpers do
        def valid_mapping?(params)
          params[:exchange].to_s != "" and params[:queue].to_s != ""
        end

        def display_flash
          [:error, :notice].map do |field|
            if params[field].to_s != ""
              "<p class='flash #{field}'>#{params[field]}</p>"
            end
          end.compact.join
        end
      end

      app.tabs << "Pubsub"
    end

  end
end

Resque::Server.register Resque::PubsubServer
