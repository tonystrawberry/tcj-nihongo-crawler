# frozen_string_literal: true

require 'selenium-webdriver'
require 'dotenv/load'

module Crawlers
  # Crawler class for scraping TCJ Nihongo website
  # and generating screenshots for each page of the books
  class TcjNihongo
    class BookFolderAlreadyExistsError < StandardError; end

    LOGIN_PAGE = 'https://tcj-nihongo.actibookone.com/auth/login'

    BOOKS_URL = [
      {
        name: '①社会・文化・地域',
        url: 'https://tcj-nihongo.actibookone.com/content/detail?param=eyJjb250ZW50TnVtIjozMzUzODAsImNhdGVnb3J5TnVtIjozNDA4M30='
      },
      {
        name: '②言語と社会',
        url: 'https://tcj-nihongo.actibookone.com/content/detail?param=eyJjb250ZW50TnVtIjozMzU0MDEsImNhdGVnb3J5TnVtIjozNDA4M30=&pNo=1'
      }, {
        name: '③言語と心理',
        url: 'https://tcj-nihongo.actibookone.com/content/detail?param=eyJjb250ZW50TnVtIjozMzU0MDUsImNhdGVnb3J5TnVtIjozNDA4M30='
      }, {
        name: '④言語と教育',
        url: 'https://tcj-nihongo.actibookone.com/content/detail?param=eyJjb250ZW50TnVtIjozMzU0MjgsImNhdGVnb3J5TnVtIjozNDA4M30=&pNo=1'
      }, {
        name: '⑤言語一般',
        url: 'https://tcj-nihongo.actibookone.com/content/detail?param=eyJjb250ZW50TnVtIjozMzU0MzAsImNhdGVnb3J5TnVtIjozNDA4M30=&pNo=1'
      }
    ].freeze

    def initialize
      @driver = Selenium::WebDriver.for :chrome
    end

    # Crawl the TCJ Nihongo website
    # and generate screenshots for each page of the books
    def crawl
      login_user

      BOOKS_URL.each do |book|
        crawl_book(book)
      end

      @driver.quit
    end

    private

    # Login to the TCJ Nihongo website
    # using the credentials from the `.env` file
    # @return [void]
    def login_user
      @driver.get(LOGIN_PAGE)

      username = @driver.find_element(id: 'login_mail')
      username.send_keys(ENV['NIHONGO_TCJ_USERNAME'])

      password = @driver.find_element(id: 'login_password')
      password.send_keys(ENV['NIHONGO_TCJ_PASSWORD'])

      login_button = @driver.find_element(id: 'login-button')
      login_button.click
    end

    # Crawl a book from the TCJ Nihongo website
    # @param book [Hash] the book to crawl
    #   @option name [String] the name of the book
    #   @option url [String] the URL of the book
    # @return [void]
    def crawl_book(book)
      url = book[:url]
      name = book[:name]

      initialize_folder(name)

      @driver.get(url)

      full_screen_button = @driver.find_element(css: 'a[onclick="triggerFullScreenFun()"]')
      full_screen_button.click

      crawl_pages(name)
    end

    # Initialize a folder with the name of the book
    # @param name [String] the name of the book
    # @raise [BookFolderAlreadyExistsError] if the folder already exists
    def initialize_folder(name)
      raise BookFolderAlreadyExistsError if File.exist?("screenshots/#{name}")

      Dir.mkdir("screenshots/#{name}")
    end

    # Crawl the pages of the book
    # @param name [String] the name of the book
    # @return [void]
    def crawl_pages(name)
      page_number = 1

      loop do
        @driver.save_screenshot("screenshots/#{name}/page_#{page_number}.png")
        @driver.action.send_keys(:arrow_right).perform

        sleep 5
        break if @driver.current_url.include?("pNo=#{page_number}")

        page_number = @driver.current_url.split('pNo=')[1].to_i
      end
    end
  end
end
