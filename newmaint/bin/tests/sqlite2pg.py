# Fake a pg interface using sqlite as backend

class db:

    def __init__(self, db):
        self.cx = db
        self.cu = self.cx.cursor()

    def query(self, sql):
        self.cu.execute(sql)
        return self

    def getresult(self):
        return self.cu.fetchall()

