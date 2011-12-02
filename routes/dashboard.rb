module UniversalTracker
  class App < Sinatra::Base
    get "/" do
      erb :index
    end

    get "/stats.json" do
      stats = tracker.stats

      content_type :json
      expires 1, :public, :must_revalidate
      JSON.dump(stats)
    end

    get "/update-status.json" do
      data = tracker.downloader_update_status

      content_type :json
      expires 60, :public, :must_revalidate
      JSON.dump(data)
    end

    get "/rescue-me" do
      erb :rescue_me
    end

    post "/rescue-me" do
      items = params[:items].to_s.downcase.scan(tracker_config.valid_item_regexp_object).map do |match|
        match[0]
      end.uniq
      if items.size > 100
        "Too many items."
      else
        new_items = tracker.add_items(items)
        tracker.log_added_items(items, request.ip)

        erb :rescue_me_thanks, :locals=>{ :new_items=>new_items }
      end
    end
  end
end
