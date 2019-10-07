import re
import io
import json
import scrapy
import pandas as pd
from bs4 import BeautifulSoup
from selenium import webdriver
from scrapy.http import TextResponse
from scrapy_tutorial.items import ScrapyTutorialItem
 

class CFEMScraper(scrapy.Spider):
    
    #Name the scraper - this is what we'll use to call the program
    name = "target"
    #Start to scrape this/these url/urls
    start_urls = ['https://www.target.com/c/shop-all-categories/-/N-5xsxf']

    #If we choose to use the "parse_selenium" function, uncomment this code to start 
    #open an instance of Firefox (or your choice of webrowser) when the program begins
    #####################COMMENT IN WHEN RUNNING "PARSE_SELENIUM"##################
    def __init__(self):
        self.driver = webdriver.Firefox()
    ###############################################################################

    #The parsing function begins the scraping process
    def parse(self, response):
        #Use XPath to generate the links (@href) for all of the products on www.target.com
        view_all = response.xpath("//li[@class='h-margin-b-tiny']/a/@href").extract()
        for link in view_all:
            #1. For each @href, make a call to the updated link (response.urljoin(link))
            #callback makes a request to the "parse_link" HTML parsing function
            #2. I add the 'meta' tag to the scrapy request. This is a method of passing data to the next 
            #parsing function and saving it for future use/parsing
            yield scrapy.Request(url=response.urljoin(link), callback=self.parse_selenium, meta={'webpage':response.urljoin(link)})
    
    #Our first function "parse_xpath" uses traditional xpath in order to find the relevant objects on the webpage
    def parse_xpath(self, response):

        #This simply prints the URL so that you know the correct links are being pulled
        print("##################")
        print(response.url)
        print("##################")
        print(response.meta)
        print("$$$$$$$$$$$$$$$$")
        #Declare a custom object imported from scrapy_tutorial.items
        data = ScrapyTutorialItem()
        data['item'] = {'url': response.meta['webpage'].split("=")[1], 'items': response.xpath("//li[@class='h-margin-b-tiny']/a/@data-lnk").extract()}
        return data 

    #Our second function "parse_selenium" leverages the selenium webrowser to crawl our websites
    def parse_selenium(self, response):

        #Use the previous instance of the webrowser which was created to go to visit the "response.url"
        self.driver.get(response.url)
        self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        #All comments have been loaded, once again pass the "body" argument back in
        response1 = TextResponse(url=response.url, body=self.driver.page_source, encoding='utf-8')
        data = ScrapyTutorialItem()
        data['item'] = {'url': response.url.split("=")[1], 'items': response1.xpath("//li[@class='h-margin-b-tiny']/a/@data-lnk").extract()}
        return data
