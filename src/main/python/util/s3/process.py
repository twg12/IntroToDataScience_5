from util.s3.manage import S3Manager


def main():
    """
        standalone process to load and save CSV file data with AWS S3
    """
    manager = S3Manager(
        bucket_name="introtodatascience5",
        key="'open_data/emergency_medical_service/origin/csv/응급의료기관현황(2014.5).csv'"
    )
    df = manager.load_csv_to_df()
    print(df)


if __name__ == '__main__':
    main()