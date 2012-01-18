module Resque
  module FanoutServer

    VIEW_PATH = File.join(File.dirname(__FILE__), 'views')

    def self.registered(app)
      # index
      app.get "/fanout/?" do
        @exchanges = Resque.exchanges
        @queues = Resque.queues
        erb(File.read(File.join(::Resque::FanoutServer::VIEW_PATH, "index.erb")))
      end

      # create new mapping
      app.post '/fanout/?' do
        if valid_mapping? params
          Resque.subscribe params[:exchange], :queue => params[:queue], :class => params[:class]
          redirect u(:fanout, "?notice=#{URI.escape 'Mapping created'}")
        else
          redirect u(:fanout, "?error=#{URI.escape 'Invalid Mapping'}")
        end
      end

      # delete mapping
      app.post '/fanout/:exchange/:queue/remove' do
        if valid_mapping? params
          Resque.unsubscribe params[:exchange], :queue => params[:queue]
          redirect u(:fanout, "?notice=#{URI.escape 'Mapping removed'}")
        else
          redirect u(:fanout, "?error=#{URI.escape 'Invalid Parameters'}")
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

      app.tabs << "Fanout"
    end

  end
end

Resque::Server.register Resque::FanoutServer
