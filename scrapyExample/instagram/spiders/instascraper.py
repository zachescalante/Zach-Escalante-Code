# -*- coding: utf-8 -*-
import scrapy
import time
from selenium import webdriver
from scrapy.http import TextResponse 
from instagram.items import InstagramItem
from collections import defaultdict


class InstascraperSpider(scrapy.Spider):
    name = "instascraper"
    allowed_domains = ["www.instagram.com"]
    start_urls = ['https://www.instagram.com/nyknicks/']
    
    def __init__(self):
        self.driver = webdriver.Firefox()

    def parse(self, response):
#       substantiate a selenium driver as the object we scrape
        self.driver.get(response.url)
        time.sleep(4)
        #scroll down so we can see the 'Load More' button
        self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        #click on the 'Load More' button
        load_more = self.driver.find_element_by_link_text('Load more')
        load_more.click()
        time.sleep(2)
        #how many times do we need to scroll down? Here I've determined once        
        for i in xrange(0, 1):
            self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            time.sleep(3)
            
       #pass the response url along with the new scrolled-down website (body = )

        response1 = TextResponse(url=response.url, body=self.driver.page_source, encoding='utf-8')  

        photo_links = response1.xpath("//a[contains(@class, '_8mlbc _vbtk2 _t5r8b')]/@href").extract()
        for photo in photo_links:
            url = response.urljoin(photo)
            #for each photo loaded on the page, callback the parse_photo function
            yield scrapy.Request(url, callback=self.parse_photo)

############################################################################
##Parse_photo is a function that scrapes all the user data from one instagram
##page. The data extracted includes: likes, time, comments (users & what they
##said/tagged, posted), location, location href and username_href. This is a 
##comprehensive function that yields a stand alone data set
############################################################################
    def parse_photo(self, response):

        self.driver.get(response.url)
        #find the 'Load More' button in the 'comments' section and load all of them
        try:
            while True:                
                self.driver.find_element_by_xpath('//button[@class="_l086v _ifrvy"]').click()
        except:
            pass
        #All comments have been loaded, once again pass the "body" argument back in
        response1 = TextResponse(url=response.url, body=self.driver.page_source, encoding='utf-8')

        li_class = response1.xpath("//li[@class='_nk46a']")

        data = InstagramItem()
        data['href'] = response1.url
        data['username'] = response1.xpath(".//header/div//a[1]/@title").extract()
        data['username_href'] = response1.xpath(".//header//div/a[1]/@href").extract()
        data['location'] = response1.xpath(".//header//div//a[2]/@title").extract()
        data['location_href'] = response1.xpath(".//header//div//a[2]/@href").extract()
        data['likes'] = response1.xpath(".//span[@class='_tf9x3']/span/text()").extract()
        data['time'] = response1.xpath(".//a[@class='_rmo1e']/time/@datetime").extract()
        data['comments'] = defaultdict()
        for i in li_class:
            try:
                data['comments'][str(i.xpath(".//a/@title").extract())] = i.xpath(".//span//text()").extract()
            except:
                pass
        yield data
        #the data is stored in a csv by the command which is run from the console
        #'scrapy crawl instascraper -o data.csv'
###########################################################################
##parse_commenters begins to follow the commenters to their pages where we
##can scrape their data. It has several callback functions, without which
##it does not provide full functionality
#
#----Collect all of the urls of each person who commented on a photo------
#    def parse_commenters(self, response):
#        
#        self.driver.get(response.url)
#        for i in xrange(0, 2):
#            try:                
#                self.driver.find_element_by_xpath('//button[@class="_l086v _ifrvy"]').click()
#            except:
#                pass
#      
#        response1 = TextResponse(url=response.url, body=self.driver.page_source, encoding='utf-8')
#        
#        user_links = response1.xpath("//a[@class='_4zhc5 notranslate _iqaka']/@href").extract()
#        for user in user_links:
#            url = response.urljoin(user)
#            yield scrapy.Request(url, callback=self.parse_commenter_hrefs)
##-----------Load all the photos of each person who commented--------------       
#    def parse_commenter_hrefs(self, response):
#
#        self.driver.get(response.url)
#        time.sleep(3)
#        posts = self.driver.find_element_by_class_name("_bkw5z").getText()
#        posts = self.driver.find_element_by_class_name("_bkw5z").text
##-------How many posts are there? How many time should we scroll down?----
#        p = int(posts)   
#        
#        self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
#        try:
#            load_more = self.driver.find_element_by_link_text('Load more')
#            load_more.click()
#        except:
#            pass
#        
#     
#        for i in xrange(0, p/12):
#            self.driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
#            time.sleep(3)
#        
#        try:
#            response1 = TextResponse(url=response.url, body=self.driver.page_source, encoding='utf-8')  
##-------For each photo on the page, call the scraping function------------
#            photo_links = response1.xpath("//a[contains(@class, '_8mlbc _vbtk2 _t5r8b')]/@href").extract()
#            for photo in photo_links:
#                url = response.urljoin(photo)
#                yield scrapy.Request(url, callback=self.parse_locations)
#        except:
#            pass
#        
##-- This function will scrape the data frome each photo and store in an object-------    
#    def parse_locations(self, response):
#        data = InstagramItem()
#        data['href'] = response.url
#        data['username'] = response.xpath("//a[@class='_4zhc5 notranslate _ook48']/@title").extract()
#        data['username_href'] = response.xpath("//a[@class='_4zhc5 notranslate _ook48']/@href").extract()
#        data['location'] = response.xpath("//a[@class='_kul9p _rnlnu']/@title").extract()
#        data['location_href'] = response.xpath("//a[@class='_kul9p _rnlnu']/@href").extract()
##        data['likes'] = response.xpath(".//span[@class='_tf9x3']/span/text()").extract()
##        data['time'] = response.xpath(".//a[@class='_rmo1e']/time/@datetime").extract()
#        yield data
#
#        
#
#            
#        
#            
#        
#            