#!/usr/bin/env python
# coding: utf-8

# In[ ]:


#List of largest corporate profits and losses from wikipedia 


# In[2]:


from bs4 import BeautifulSoup
import requests


# In[3]:


url = 'https://en.wikipedia.org/wiki/List_of_largest_corporate_profits_and_losses'


# In[4]:


website = requests.get(url)


# In[5]:


soup = BeautifulSoup(website.text, 'html')


# In[6]:


print(soup)


# In[7]:


soup.find_all('table')


# In[8]:


soup.find_all('table')[0]


# In[9]:


required_table=soup.find_all('table')[0]


# In[10]:


table_headers=required_table.find_all('th')


# In[11]:


table_headers


# In[65]:


table_headers_text = [header.text.strip() for header in table_headers]


# In[66]:


table_headers_text


# In[18]:


import pandas as pd


# In[70]:


df = pd.DataFrame(columns=table_headers_text)


# In[71]:


df


# In[72]:


table_row = required_table.find_all('tr')


# In[73]:


for row in table_row [1:]  :
    row_data = row.find_all('td')
    individual_row_data = [data.text.strip() for data in row_data]
    length = len(df)
    df.loc[length] = individual_row_data


# In[74]:


df


# In[77]:


df.to_csv(r'D:\Mohamed\Data science\Data analysis\PROJECTS\7- Wikipedia web scraping using python\wikipediaWebScraping.csv',index = False)


# In[ ]:




