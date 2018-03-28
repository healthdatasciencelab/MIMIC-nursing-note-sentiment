import os
import pandas as pd
from textblob import TextBlob
from textblob.sentiments import NaiveBayesAnalyzer

script_dir = os.path.dirname(__file__)
rel_path = '~/path to project/Data/notes_df.csv'
abs_file_path = os.path.join(script_dir, rel_path)

nursing_notes_df = pd.read_csv(abs_file_path, header=0)
polarity_vals = []
subjectivity_vals = []

nursing_notes_df_sample = nursing_notes_df
count = 1
for note in nursing_notes_df_sample['text']:
	tb = TextBlob(note)
	polarity_vals.append(tb.sentiment.polarity)
	subjectivity_vals.append(tb.sentiment.subjectivity)
	if count % 1000 == 0:
		print("Processed note #" + str(count))
	count += 1

nursing_notes_df_sample['polarity'] = polarity_vals
nursing_notes_df_sample['subjectivity'] = subjectivity_vals

nursing_notes_df_sample.to_csv("~/path to project/Data/notes_df_sntmnt.csv")
