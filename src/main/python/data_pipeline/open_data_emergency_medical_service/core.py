import pandas as pd

from util.logging import init_logger
from util.s3.manage import S3Manager


class OpenDataEmergencyMedicalService:

    def __init__(self, bucket_name: str = "introtodatascience5", file_name: str = ""):
        self.logger = init_logger()

    # TODO: create s3 or rds bucket and fill s3
        # s3
        self.bucket_name = bucket_name
        self.file_name = file_name

        self.load_key = "open_data/emergency_medical_service/origin/csv/{filename}".format(
            filename=self.file_name
        )
        self.save_key = "open_data/emergency_medical_service/process/csv/{filename}.csv".format(
            filename=self.file_name
        )
        self.input_df = self.load(bucket_name=self.bucket_name, key=self.load_key)
        print(self.input_df)

    def load(self, bucket_name, key):
        """
            fetch DataFrame and ckeck validate
        :return: pd.DataFrame
        """
        manager = S3Manager(bucket_name=bucket_name)
        df = manager.fetch_objects(key=key)

        return df[0]

    def filter(self, df: pd.DataFrame ):
        """
        remove unused column
        :param df: df to be filtered
        :return: filtered pd.DataFrame
        """
        return df

    def clean(self, df: pd.DataFrame):
        """
        check null & fill
        :param df: df to be cleaned
        :return: cleaned pd.DataFrame
        """
        return df

    def transform(self, df: pd.DataFrame):
        """
        transform dataframe as proper reason
        :param df: df to be transform ( log transform or nomalization etc .. )
        :return: transformed pd.DataFrame
        """
        return df

    def save(self, df: pd.DataFrame):
        """
        save processed df to s3
        :param df: processed dataframe to be save(s3)
        """

    def process(self):
        """
            1. filter ( remove unused columns )
            2. null handling ( check null value & fill )
            3. transform as distribution of data
            TODO: think about process steps

        :return: exit code (bool) 0: success 1: fail
        """
        try:
            filtered_df = self.filter(self.input_df)
            clean_df = self.clean(filtered_df)
            transformed_df= self.transform(clean_df)
            # TODO: make df according to process steps

            self.save(transformed_df)

        except IOError as e:
            self.logger.critical(e, exc_info=True)
            return 1  # fail to process

        self.logger.info("success to process emergency_medical_service")

        return 0  # success!

