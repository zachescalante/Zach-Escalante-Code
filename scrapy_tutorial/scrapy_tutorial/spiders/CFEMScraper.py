import re
import io
import json
import scrapy
import pandas as pd
from scrapy_tutorial.items import ScrapyTutorialItem
from scrapy.http import TextResponse 
from selenium import webdriver
from bs4 import BeautifulSoup


class CFEMScraper(scrapy.Spider):
    
    #Name the scraper - this is what we'll use to call the program
    name = "target"
    #Start to scrape this/these url/urls
    start_urls = ['https://www.target.com/c/shop-all-categories/-/N-5xsxf']

    def __init__(self):
        self.driver = webdriver.Firefox()

    #The parsing function begins the scraping process
    def parse(self, response):
        #Use XPath to generate the links (@href) for all of the products on www.target.com
        view_all = response.xpath("//li[@class='h-margin-b-tiny']/a/@href").extract()
        for link in view_all:
            #1. For each @href, make a call to the updated link (response.urljoin(link))
            #callback makes a request to the "parse_link" HTML parsing function
            #2. I add the 'meta' tag to the scrapy request. This is a method of passing data to the next 
            #parsing function and saving it for future use/parsing
            yield scrapy.Request(url=response.urljoin(link), callback=self.parse_xpath, meta={'webpage':response.urljoin(link)})
    #Our first function 
    def parse_xpath(self, response):
    	print("##################")
    	print(response.url)
    	print("##################")
        #Declare a custom object imported from scrapy_tutorial.items
        data = ScrapyTutorialItem()
        data['item'] = {'url': response.meta['webpage'].split("=")[1], 'items': response.xpath("//div[@class='ItemTitle-sc-1bls9ac-0 hrhyAs']/text()").extract()}
        return data

    def parse_selenium(self, response):
        self.driver.get(response.url)
        self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        #All comments have been loaded, once again pass the "body" argument back in
        response1 = TextResponse(url=response.url, body=self.driver.page_source, encoding='utf-8')
        data = ScrapyTutorialItem()
        data['item'] = {'url': response.url.split("=")[1], 'items': response1.xpath("//div[@class='ItemTitle-sc-1bls9ac-0 hrhyAs']/text()").extract()}
        return data
