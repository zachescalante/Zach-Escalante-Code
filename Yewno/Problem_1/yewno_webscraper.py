#This file scrapes the Publix Digital Coupon webpage using Selenium to 
#initalize the webpage and scroll to the bottom, then BeatifulSoup to search
#each node and collect the coupon data before converting it to a dataframe
#and exporting it to a CSV file.
import re
import os
import sys
import time
import pandas as pd
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.keys import Keys

os.chdir('/Users/zacharyescalante/Desktop')

website = 'https://www.publix.com/savings/coupons/digital-coupons'
driver = webdriver.Firefox()
driver.get(website)

#Selenium documentation
#http://selenium-python.readthedocs.io

###########################################################################
#Scrolling down two full pages will load the button for ust to click which
#will show us the full list of coupons which we can then scroll down
for i in range(0, 2):
    #Java script
    driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
    time.sleep(2)
    i = i + 1

#Selenium is the only package that enables users to navigate a webpage and 
#click javea-enabled buttons
driver.find_element_by_xpath("//button[@class='btn btn-large js-btnLoadCoupons']").click()

##################################X-PATH###################################
#https://www.w3schools.com/xml/xpath_syntax.asp
###########################################################################

#I find a tag which I can use to scroll down. I need this in order to 
#collect the first tag from which I can find enough sibling tags to scroll 
#all the way to the bottom of the page and make sure all the data is loaded

dc_card = driver.find_element_by_xpath("//div[@class='dc-card']")

while True:
    try:
        print(dc_card)
        #Here I am setting the new dc_card to the sibling of the previous dc-card
        #I have to specify exactly which tag I want to use next as the sibling
        dc_card = dc_card = dc_card.find_element_by_xpath(".//following-sibling::div[@class='dc-card']")
        dc_card.send_keys(Keys.PAGE_DOWN)
        time.sleep(3)
    except:
        break
    
#At this point I choose to initialize a BeautifulSoup object due to ease of
#traversal from each of the nodes.
soup = BeautifulSoup(driver.page_source)
dc_card_inner = soup.find_all("div", class_="dc-card")
#I can print out the length of the 'dc_card_inner' object to make sure I'm
#collecting all the objects
#print len(dc_card_inner)

i = 0
dict_ = {}
for item in dc_card_inner:
    i +=1 
    savings = item.find('h4', {'class': 'dc-card-title'}).text.strip()
    product_details = item.find('p', {'class': 'dc-card-description'}).text.strip()
    expiry = item.find('div', {'class': 'dc-card-info'}).text.strip()
    dict_[i] = {'Savings': savings, 'Expiration': expiry, 'Details': product_details}
df = pd.DataFrame.from_dict(dict_, orient = 'index')
df.to_csv('coupons.csv')
driver.close()
sys.exit()

