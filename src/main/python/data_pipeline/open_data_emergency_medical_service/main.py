from data_pipeline.open_data_emergency_medical_service.core import OpenDataEmergencyMedicalService


def main():
    open_data_emergency_medical_service = OpenDataEmergencyMedicalService(
        file_name="응급의료기관현황(2014.5).csv"
    )
    # open_data_emergency_medical_service.process()


if __name__ == '__main__':
    main()
