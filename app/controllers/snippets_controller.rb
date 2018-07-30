
require 'net/http'
require 'uri'
require 'json'
require 'color-generator'


class SnippetsController < ApplicationController
  before_action :set_snippet, only: [:show, :edit, :update, :destroy]

  # GET /snippets/1
  # GET /snippets/1.json
  def show
    generator = ColorGenerator.new saturation: 0.3, lightness: 0.75
    @nickname = generate_nick_name
    @snippet = Snippet.find_by slug: params[:slug]
  end

  def stream

    generator = ColorGenerator.new saturation: 0.3, lightness: 0.75

    @snippet = Snippet.find_by slug: params[:slug]
    @nickname = generate_nick_name
    
    unless @snippet
      @snippet = Snippet.new
      @snippet.language = "javascript"
      @snippet.slug = params[:slug] || SecureRandom.base64
      @snippet.save
    end
    session[:current_snippet] = @snippet.slug
  end

  # GET /snippets/new
  def generate_nick_name
    uri = URI.parse("https://api.codetunnel.net/random-nick")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json" 
    request.body = JSON.dump({})
    req_options = { use_ssl: uri.scheme == "https" }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    json = JSON.parse(response.body)
    return json["nickname"]

  end 
     

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_snippet
      @snippet = Snippet.find_by slug: params[:slug]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def snippet_params
      params.require(:snippet).permit(:id, :code, :title, :language, :stack, :slug)
    end
end
