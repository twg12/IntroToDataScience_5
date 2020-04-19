from datetime import datetime
import pandas as pd

from util.logging import init_logger


class OpenDataEmergencyMedicalService:

    def __init__(self, bucket_name: str = "", location: str = ""):
        self.logger = init_logger()

    # TODO: create s3 or rds bucket and fill s3
        # s3
        self.bucket_name = bucket_name
        self.file_name = ""

        self.load_key = "()/()/()/{filename}".format(
            filename=self.file_name
        )
        self.save_key = "public_data/open_data_marine_weather/process/csv/{filename}.csv".format(
            filename=location
        )

    def load(self):
        """

        :return: pd.DataFrame
        """
        manager = S3Manager(bucket_name=self.bucket_name)
        df = manager.fetch_objects(key=self.load_key)

        return pd.DataFrame
        pass

    def process(self):
        pass

