# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class InstagramItem(scrapy.Item):
    # define the fields for your item here like:
    href = scrapy.Field()
    likes = scrapy.Field()
    time = scrapy.Field()
    username = scrapy.Field()
    username_href = scrapy.Field()
    location = scrapy.Field()
    location_href = scrapy.Field()
    comments = scrapy.Field()
    pass
