#This file scrapes the Publix Digital Coupon webpage using Selenium to 
#initalize the webpage and scroll to the bottom, then BeatifulSoup to search
#each node and collect the coupon data before converting it to a dataframe
#and exporting it to a CSV file.

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup
import pandas as pd
import time
import re

website = 'https://www.publix.com/savings/coupons/digital-coupons'
driver = webdriver.Firefox()
driver.get(website)
down = driver.find_element_by_class_name('row')
#I find a tag which I can use to scroll down. I need this in order to 
#collect the first tag from which I can find enough sibling tags to scroll 
#all the way to the bottom of the page and make sure all the data is loaded
down.send_keys(Keys.PAGE_DOWN)
time.sleep(2)
elem = driver.find_element_by_xpath("//div[@data-couponid]")

i = 1
while True:
    try:
#       find the ith sibling of the first 'elem' instance 
        elem = elem.find_element_by_xpath("//div[@data-couponid]/following-sibling::*[%d]" % i)
        time.sleep(2)
#       scroll down the page        
        elem.send_keys(Keys.PAGE_DOWN)
        i +=10
    except:
        break
    
#At this point I choose to initialize a BeautifulSoup object due to ease of
#traversal from each of the nodes.
soup = BeautifulSoup(driver.page_source)
dc_card_inner = soup.find_all("div", class_="dc-card-inner")
#I can print out the length of the 'dc_card_inner' object to make sure I'm
#collecting all the objects
#print len(dc_card_inner)

dict_ = {}

for item in dc_card_inner:
        savings = item.find("h4").get_text().encode('utf-8')
        product_details = item.find("p", class_="dc-subtitle").get_text().replace(u"\u2122", '').encode('utf-8')
        span = item.find("span", class_="dc-expiration").get_text()
        span = re.split('\s+', span)[1].encode('utf-8')
        detail = item.find("div", class_="dc-detail-scroll").get_text().strip('\n').encode('utf-8')
        photo = item.findAll("img")
        result = re.findall(r'"(.*?)"', str(photo[0]))
        dict_[result[0]] = {'Savings': savings, 'Expiration': span, 'Details': detail, 
                            'Product Details': product_details}
        df = pd.DataFrame.from_dict(dict_, orient = 'index')
        df.to_csv('coupons.csv')
driver.close()

