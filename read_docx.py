from docx import Document

doc = Document(r'c:\Users\cxf33\Desktop\数据库--校园集市\校园集市数据库设计（优化版） (1).docx')

for paragraph in doc.paragraphs:
    print(paragraph.text)
