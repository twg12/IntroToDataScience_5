from util.s3.manage import S3Manager


def main():
    """
        standalone process to load and save CSV file data with AWS S3
    """
    manager = S3Manager(
        bucket_name="introToDataScience_5",
    )
    df_list = manager.fetch_objects(key="")
    print(df_list)


if __name__ == '__main__':
    main()