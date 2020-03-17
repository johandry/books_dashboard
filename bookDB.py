#!/usr/bin/env python3

import os
import sys
import pandas as pd

defOutFilename = 'books_db'

# the following filenames and extensions are not from books
non_books_filenames = ['.DS_Store', '_source']
non_books_extension = ['.mp3', '.mp4', '.m4v', '.sh', '.jpg']

class Book:
  def __init__(self, dirname, filename):
    self.path = os.path.join(dirname, filename)
    self.filename = filename
    file_parts = os.path.splitext(filename)
    self.title = file_parts[0]
    self.format = file_parts[1].upper()[1:]

  def print(self):
    print(f'Title: {self.title}, Format: {self.format}, Path: {self.path}')

  def to_dict(self):
    return {
      'title': self.title,
      'format': self.format,
      'filename': self.filename,
      'path': self.path,
    }

  @staticmethod
  def isBook(filename):   
    filename = filename.lower()
    if filename in non_books_filenames or os.path.splitext(filename)[1] in non_books_extension:
      return False
    return True

class Books:
  def __init__(self, base_dir):
    self.base_dir = base_dir
    self.books = []
    self.not_books = []
    self.dataframe = None


  def append(self, dirname, filename):
    if not Book.isBook(filename):
      self.not_books.append(os.path.join(dirname, filename))
      return 

    b = Book(dirname, filename)
    self.books.append(b)

  def collect(self):
    for root, _, files in os.walk(self.base_dir):
      for file in files:
        self.append(root, file)
    self.refresh_dataframe()
    

  def refresh_dataframe(self):  
    books_list = []
    for b in self.books:
      books_list.append(b.to_dict())
    self.dataframe = pd.DataFrame(books_list)

  def print(self):
    for b in self.books:
      b.print()

  def to_csv(self, filename=''):
    if filename == '':
      filename = defOutFilename+'.csv'
    df = self.dataframe
    df.to_csv(filename)

    return filename

  def export_non_books(self, filename=''):
    if filename == '':
      filename = defOutFilename+'_non_books.txt'
    with open(filename, 'w') as f:
      for nb in self.not_books:
        f.write(nb+"\n")

    return filename

def main(baseDir):
  books = Books(baseDir)
  books.collect()
  fname = books.to_csv()
  print(f'CSV saved to {fname}')
  fname = books.export_non_books()
  print(f'Non books saved to {fname}')

def help(prog_name):
  h = (
    'usage: '+prog_name+' <books_directory> \n'
    '\n'
    'Creates the books dashboard as CSV and HTML. It also reports all the files that are not books.\n'
    'where:\n'
    'books_directory: is the base directory for all the books'
  )
  print(h)
  sys.exit(1)

if __name__ == "__main__":
  if len(sys.argv) <= 1:
    help(sys.argv[0])
  baseDir = sys.argv[1]

  main(baseDir)