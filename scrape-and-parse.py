#!/usr/bin/env python -OO
# -*- coding: utf-8 -*-

import urllib2  # html scraper
from bs4 import BeautifulSoup  # html parser. More info at http://www.crummy.com/software/BeautifulSoup/
import sys  # exit quits program prematurely in event of error
import sqlite3  # allows interaction with sql database (henceforth db)
import datetime  # strptime and strftime convert between date formats
import time  # sleep allows slight pause after each request to pitchfork's servers
import numpy  # random.exponential determines variable sleep time between server requests; more human-like, for what it's worth.
import itertools  # count function is convenient iterator
import signal  # handles Timeout errors, in case scrape/parse takes too long. Only works on UNIX-based OS, sorry Windows users.

# global variables
BASE_URL = 'http://www.pitchfork.com'
OPENER = urllib2.build_opener()
OPENER.addheaders = [('User-agent', 'Mozilla/5.0')]  # perhaps disingenuous, but claims web scraper is a user-agent vs bot
AVERAGE_SECONDS_BETWEEN_REQUESTS = 5  # that being said, be kind to pitchfork's servers
START_AT_PAGE = 1  # album review page at which to begin scraping/parsing. May need to update this if program hangs and must be rerun.
DATABASE_NAME = 'pitchfork-reviews.db'  # must end in .db

class Timeout(Exception):  # handles timeout errors (e.g., server request is taking too long)
	pass

def main():
	"""Loop through all pages and parse their albums."""
	con = None  # initialize to None in case connection with db cannot be made
	try:
		con, sql = create_sql_db(DATABASE_NAME)  # con is connection to db, sql is cursor to interact with db
		for page in itertools.count(START_AT_PAGE):
			href = '/reviews/albums/%s' % page
			html = scrape_html(href)
			if not html:  # scrape_html fails to open BASE_URL + href because it does not exist (i.e., no more pages left)
				print "Done parsing"
				break
			if html:
				parse_page(sql, html)  # inserts 20 albums into db
				con.commit()  # commit changes to db after page fully parsed
				time.sleep(numpy.random.exponential(AVERAGE_SECONDS_BETWEEN_REQUESTS, 1))  # pause between server requests

	except sqlite3.Error, e:
		print 'Error: %s' % e.args[0]
		sys.exit(1)

	finally:  # close connection to db before exiting
		if con:
			print "Closing connection to database"
			con.close()

def create_sql_db(db_name):
	print "Opening connection to database"
	con = sqlite3.connect(db_name)
	sql = con.cursor()
	sql.execute("""CREATE TABLE IF NOT EXISTS albums(
		id INTEGER PRIMARY KEY,
		album TEXT,
		artist TEXT,
		label TEXT,
		released INTEGER,
		reviewer TEXT,
		score NUMERIC,
		accolade TEXT,
		published TEXT,
		url TEXT
	);""")
	sql.execute("""CREATE TABLE IF NOT EXISTS artists(
		id INTEGER PRIMARY KEY,
		artist TEXT,
		url TEXT
	);""")
	sql.execute("""CREATE TABLE IF NOT EXISTS labels(
		label TEXT PRIMARY KEY
	);""")
	sql.execute("""CREATE TABLE IF NOT EXISTS reviewers(
		reviewer TEXT PRIMARY KEY,
		url TEXT
	);""")
	return con, sql

def scrape_html(href):
	"""Scrapes html from a single url."""
	url = BASE_URL + href
	html = None
	try:
		response = OPENER.open(url)
		if response.code == 200:
			print "Scraping %s" % url
			html = response.read()
		else:
			print "Invalid URL: %s" % url
	except urllib2.HTTPError:
		print "Failed to open %s" % url
	return html

def parse_page(sql, html):
	"""Parses an index page of 20 albums."""
	# get album index
	index = BeautifulSoup(html, 'lxml').find('ul', class_ = 'object-grid')
	# iterate through albums
	for a in index.findAll('a'):
		album_href = a.get('href')
		album_id  = album_href[16: ].split('-')[0]
		if not sql.execute("SELECT 1 FROM albums WHERE id = ?;", (album_id, )).fetchone():  # if album does not exist in db
			parsed = False
			attempts = 0
			while not parsed and attempts < 3:  # attempt to parse 3 times until moving on
				try:
					parsed = parse_album(sql, album_href, album_id)
				except:
					attempts += 1
				if not parsed and attempts == 3:
					print 'Unable to parse %s' % (BASE_URL + album_href)
				time.sleep(numpy.random.exponential(AVERAGE_SECONDS_BETWEEN_REQUESTS, 1))  # pause between server requests

def parse_album(sql, album_href, album_id):
	"""Parses a single album."""
	old_handler = signal.signal(signal.SIGALRM, handler)  # save current signal handler
	t = 3
	signal.alarm(t) # trigger alarm in t seconds
	try:
		info = BeautifulSoup(scrape_html(album_href), 'lxml').find('div', class_ = 'info')  # scrape album info
		# first, parse album-specific info
		artist = info.h1.get_text()
		if artist == 'Various Artists':  # direct all 'Various Artists' to same artist page and artist id
			artist_href = '/artists/31016-various-artists/'
		else:
			artist_href = info.h1.a.get('href') 
		artist_id = artist_href[9: ].split('-')[0]
		album = info.h2.get_text()
		info_h3 = info.h3.get_text().strip()
		if '; ' in info_h3:  # if label AND year released
			label, released = info_h3.split('; ')
		else:  # else just label, year released is None
			label = info_h3[0:(-1)]
			released = None
		# second, parse pitchfork's review
		reviewer = info.h4.address.get_text()
		reviewer_href = info.h4.a.get('href')  # note: some reviewers do not have personal pages, href is just /staff/
		score = info.find('span', class_ = 'score').get_text().strip()
		accolade = None
		if info.find('div', class_ = 'bnm-label'):  # in early days of pitchfork, no accolades were given
			accolade = info.find('div', class_ = 'bnm-label').get_text().strip()  # may simply be blank
		published = info.h4.find('span', class_ = 'pub-date').get_text()
		published = datetime.datetime.strptime(published, '%B %d, %Y').strftime('%Y-%m-%d')
		data = [album, album_id, BASE_URL + album_href, artist, artist_id, BASE_URL + artist_href, 
				label, released, reviewer, BASE_URL + reviewer_href, score, accolade, published]
		print ' Parsing %s' % (BASE_URL + album_href)
		insert(sql, data)  # place in db
		return True
	except Timeout:  # in event that scrape or parse takes too long, raise timeout error
		print('{} timed out after {} seconds'.format(func.__name__, t))
		return False
	finally:
		signal.signal(signal.SIGALRM, old_handler)  # restore old signal handler
		signal.alarm(0)  # cancel the timer if function ended before the alarm

def insert(sql, data):
	"""Inserts the given data into the database."""
	# data is [album, album_id, album_url, artist, artist_id, artist_url, label, 
	#          released, reviewer, reviewer_url, score, accolade, published]
	sql.execute("INSERT OR IGNORE INTO albums VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);", 
		(data[1], data[0], data[3], data[6], data[7], data[8], data[10], data[11], data[12], data[2], ))
	sql.execute("INSERT OR IGNORE INTO labels (label) VALUES (?);", (data[6], ))
	sql.execute("INSERT OR IGNORE INTO reviewers (reviewer, url) VALUES (?, ?);", (data[8], data[9], ))
	sql.execute("INSERT OR IGNORE INTO artists VALUES (?, ?, ?);", (data[4], data[3], data[5], ))

def handler(signum, frame):
	"""Handles signal alarm."""
	raise Timeout()

if __name__ == "__main__":
	main()