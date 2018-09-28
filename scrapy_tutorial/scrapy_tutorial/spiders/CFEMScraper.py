import re
import io
import json
import scrapy
import pandas as pd


class CFEMScraper(scrapy.Spider):
    
    #Name the scraper - this is what we'll use to call the program
    name = "target"
    #Start to scrape this/these url/urls
    start_urls = ['https://www.target.com/c/shop-all-categories/-/N-5xsxf']

    #The parsing function begins the scraping process
    def parse(self, response):
        #Use XPath to generate the links (@href) for all of the products on www.target.com
        view_all = response.xpath("//li[@class='h-margin-b-tiny']/a/@href").extract()
        for link in view_all:
            #For each @href, make a call to the updated link (response.urljoin(link))
            #callback makes a request to the "parse_link" HTML parsing function
            yield scrapy.Request(url=response.urljoin(link), callback=self.parse_link)

    def parse_link(self, response):
    	print("##################")
    	print(response.url)
    	print("##################")
        for item in response.xpath("//div[@class='ItemTitle-sc-1bls9ac-0 hrhyAs']/text()").extract():
            print(item)
        return None
