from sqlalchemy import create_engine, exc, inspect, text
from exprev.db.resultset import Record, RecordCollection

class Connection:
    def __init__(self, connection):
        self.__dbcon = connection
        self.__open = not connection.closed

    def close(self):
        self.__dbcon.close()
        self.__open = False

    def __enter__(self):
        return self

    def __exit__(self, exc, val, traceback):
        self.close()

    def __repr__(self):
        return '<Connection open={}>'.format(self.__open)

    def query(self, query, fetchall=False, **params):
        # Execute the given query.
        cursor = self.__dbcon.execute(text(query), **params) 

        # Row-by-row Record generator.
        row_gen = (Record(cursor.keys(), row) for row in cursor)

        # Convert psycopg2 results to RecordCollection.
        results = RecordCollection(row_gen)

        # Fetch all results if desired.
        if fetchall:
            results.all()

        return results