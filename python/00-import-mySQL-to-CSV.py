import mysql.connector
import pandas as pd


connection = mysql.connector.connect(host='localhost',
                                         database='salary_lt',
                                         user='root',
                                         password='palydovai')

sql_query = pd.read_sql_query('''
                              select * from employees
                              '''
                              , connection)

df = pd.DataFrame(sql_query)
df.to_csv ('../Data/SQLout_employees.csv', index = False)
