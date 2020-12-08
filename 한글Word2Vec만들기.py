# imports needed and logging
from __future__ import unicode_literals
import gzip
import gensim
import logging
from gensim.models import Word2Vec

# gensim을 가지고 실행함

class word2vecManager:
    def __init__(self):
        name = "word2vecManager"

    def read_input(self, input_file):
        """This method reads the input file which is in gzip format"""
        logging.info("reading file {0}...this may take a while".format(input_file))
        with gzip.open(input_file, 'rb') as f:
            for i, line in enumerate(f):
                if (i % 10000 == 0):
                    logging.info("read {0} reviews".format(i))
                # do some pre-processing and return list of words for each review
                # text
                yield gensim.utils.simple_preprocess(line)


    def train(self, documents, modelFile):
        # build vocabulary and train model
        model = gensim.models.Word2Vec(
            documents,
            size=300, # dimension
            window=5,
            sg=0, 
            min_count=100, # text를 큰 거쓰면 여기 바꿔도 됨, model 만들려면 몇백만개는 데이터가 있어야함
            workers=10)  # multi threading
        model.train(documents, total_examples=len(documents), epochs=50)
        model.wv.save_word2vec_format(modelFile, binary=True)  # binary= False로 하면...오류가남...
        # binary : bool, optional If True, the data will be saved in binary word2vec format, else it will be saved in plain text.

    def load(self, modelFile):
        model = gensim.models.KeyedVectors.load_word2vec_format(modelFile, binary=True, unicode_errors='ignore')
        return model


if __name__ == '__main__':
    import pyTextMiner as ptm
    import io
    import nltk
    # 전처리
    corpus = ptm.CorpusFromFile('../corpus_tot.txt')
    pipeline = ptm.Pipeline(ptm.splitter.NLTK(), ptm.tokenizer.Komoran(),
                            ptm.helper.POSFilter('NN*'),
                            ptm.helper.SelectWordOnly(), # 품사가 있는건 버리고 단어만 남김
                            ptm.helper.StopwordFilter(file='../stopwordsKor.txt'),
                            ptm.ngram.NGramTokenizer(2))  # uni gram, bi gram, tri gram

    result = pipeline.processCorpus(corpus)
    # break it...?을 하나만 남기려고 for loop 3번 씀
    text_data = []
    for doc in result:
        new_doc = []
        for sent in doc:
            for _str in sent:
                if len(_str) > 0:
                    new_doc.append(_str)
        text_data.append(new_doc)
# ------------------------------------------------------------이 위는 전처리
    # train -> test 순서
    mode = 'train'
    model_file = 'w2v_ssk.model'
    if mode == 'train':
        word2vecManager().train(text_data, model_file)
    else:
        model = word2vecManager().load(model_file)
        # Some predefined functions that show content related information for given words
        try:
            print(model.most_similar(positive=['이재명'], topn=5))
            print(model.similar_by_word('이재명'))
            # print("distance " + model.distance('이재명', '문재인'))

        except:
            print('not found')
