import csv
from typing import List, Any, Union

import pandas as pd
import pyTextMiner as ptm
#import kistepProject as kp
import re
#from nltk.tag import pos_tag
#import nltk; nltk.download('averaged_perceptron_tagger')
brand = 'kia'
def preprocessing_english():
    tweet_raw = pd.read_csv('./SuperbowlData/클린하고유저거름/user정리_{}_2019_09_23_to_2019_10_02.csv'.format(brand), encoding = 'utf-8', header = 0)
    #cols = ['sentiment', 'id', 'date', 'query_string', 'user', 'text'] #this is for sentiment140 preprocess
    #colds = ['date','time','user_name','text','link','retweet_counts','favorite_counts'] #this is for collected tweets data via GOT3
    #tweet_raw = pd.read_csv("./data/sentiment140_training.1600000.processed.noemoticon.csv", encoding = 'latin-1', header = None, names = cols) #this is for sentiment140 data preprocess
    #tweet_raw = pd.read_csv("./SuperbowlData/클린하고유저거름/필터_clear_Kia_twitter_data_2019-01-31_to_2019-02-07.csv", encoding = 'utf-8', header = 0)
    print(tweet_raw['text'][:5])
    #tweet_raw = tweet_raw[0:5] #for test
    corpus = []
    for i in range(len(tweet_raw)):
        doc = str(tweet_raw['text'][i])
        doc = doc.replace("[", "").replace("]", "").replace("%", "").replace("? 셳", "'t").replace("?셳", "'t").replace("? 셲", "'s").replace("?셲", "'s")\
            .replace("? 쁥", "'h").replace("?쁥", "'h").replace("? 쁲", "'s").replace("?쁲", "'s").replace("? 셱", "'r").replace("?셱", "'r").replace("? 쁳", "'t").replace("?쁳", "'t")\
            .replace("? 셫", "'m").replace("?셫", "'m").replace("? 쁶", "'w").replace("?쁶", "'w").replace("? 쐏", "'p").replace("?쐏", "'p").replace("? 쐌", "'M").replace("?쐌", "'M")\
            .replace("? 셙", "'a").replace("?셙", "'a").replace("? 쏧", "'I").replace("?쏧", "'I").replace("훮", "ā").replace("? 셶", "'v").replace("?셶", "'v")\
            .replace("? 쏷", "'T").replace("?쏷", "'T").replace("? 쏝", "'B").replace("?쏝", "'B").replace("? 셪", "'l").replace("?셪", "'l").replace("? 쐙", "'y").replace("?쐙", "'y")\
            .replace("짙", "£").replace("?쏪", "'J").replace("챕", "é").replace("? 쏻", "'W").replace("?쏻", "'W").replace("? 쐓", "'S").replace("?쐓", "'S")\
            .replace("훮", "ā").replace("? 쐁", "'C").replace("?쐁", "'C").replace("竊쉎", ": h").replace("竊", "(").replace("? 쐌", "'m").replace("?쐌", "'m").\
            replace("? 쒴", "'K").replace("?쒴", "'K").replace("? 쐆", "'h").replace("?쐆", "'h").replace("? 셎", "'S").replace("?셎", "'S").replace("? 쁅", "'F").replace("?쁅", "'F")\
            .replace("? 쐔", "'T").replace("?쐕", "'T").replace("?죛", " s").replace("?쒋?", "'' ").replace("? 쏞", "'C").replace("?쏞", "'C").replace("? 쏱", "'P").replace("?쏱", "'P")\
            .replace("? 셝", "'d").replace("?셝", "'d").replace("? 쏽", "'Y").replace("?쏽", "'Y").replace("? 쏫", "'K").replace("?쏫","'K").replace("? 쏤", "'F").replace("?쏤", "'F")\
            .replace("? 쏦", "'H").replace("?쏦", "'H").replace("&amp;", "and").replace("? 쏺", "'V").replace("?쏺", "'V")\
            .replace("? 쏛", "'A").replace("?쏛", "'A").replace("? 쏡", "'S").replace("?쏡", "'S").replace("? 쐍", "'n").replace("?쐍", "'n").replace("?㏇뇰?▧?", "").replace("? 쐊", "'k").replace("?쐊", "'k")
        doc = re.sub("@[\d|A-Z|a-z|_.]+", "", doc) #사용자태그 삭제
        doc = re.sub("(http|https|ftp|telnet|news|mms)://[^\"'\s()]+", "", doc) #url 삭제
        doc = doc.replace("'ve", " have").replace("'s", " is").replace("n't", " not").replace("'m", " am").replace("'ll", " will").replace("'d", "would")
        doc = doc.lower()
        #doc = re.sub("[^a-zA-Z]", " ", doc) #특수문자 삭제
        doc = re.sub("[^A-Za-z.?!\s]", " ", doc)
        corpus.append("{}".format(doc))  # .split("."))

    pipeline1 = ptm.Pipeline(ptm.splitter.NLTK(), ptm.tokenizer.Word(),
                           ptm.helper.StopwordFilter(file='./stopwordsEng.txt'),
                           ptm.tagger.NLTK(), ptm.lemmatizer.WordNet(),
                           ptm.helper.SelectWordOnly())  ##, kp.ngram.NGramTokenizer())
    #Below: LDA를 위한 다른 파이프라인...
    pipeline2 = ptm.Pipeline(ptm.splitter.NLTK(), ptm.tokenizer.Word(),
                           ptm.helper.StopwordFilter('./data/english_stopwords.txt'),
                           ptm.tagger.NLTK(), ptm.lemmatizer.WordNet(), ptm.helper.POSFilter('N*', 'J*'),
                           ptm.helper.SelectWordOnly())

    result1 = pipeline1.processCorpus(corpus)
    #result2 = pipeline2.processCorpus(corpus)

    f_output = open('./전처리/preprocessed/전처리최종_앱티브_2019{}.csv'.format(brand), 'w', encoding='utf-8', newline='')
    csv_writer = csv.writer(f_output) # quoting = csv.QUOTE_ALL)
    #csv_writer.writerow(['sentiment', 'id', 'date', 'query_string', 'user', 'text'])


    for i, doc in enumerate(result1):
        #doc =  re.sub('[\W]', '', doc) #특수문자 삭제
        # Remove punctuations and numbers
        #doc = re.sub('[^a-zA-Z]', ' ', doc)
        # Single character removal
        #doc = re.sub(r"\s+[a-zA-Z]\s+", ' ', doc)
        # 길이가 2이하인 단어는 제거 (길이가 짧은 단어 제거)
        '''
        for w in doc:
            w = re.sub('[^a-zA-Z]', ' ', w)
            w = re.sub(r"\s+[a-zA-Z]\s+", ' ', w)
            if len(w)>2 :
                doc = doc.append(' '.join(w))
        '''

        #print(i, doc)
        sent = list(map(" ".join, doc))
        #csv_writer.writerow([tweet_raw['sentiment'][i], tweet_raw['id'][i], tweet_raw['date'][i], tweet_raw['query_string'][i], tweet_raw['user'][i],"{}".format(" ".join(sent))]) #not this. don't use
        csv_writer.writerow([tweet_raw['date'][i], tweet_raw['time'][i], tweet_raw['user_name'][i], " ".join(sent)])


preprocessing_english()
