from data_pipeline.open_data_emergency_medical_service.core import OpenDataEmergencyMedicalService


def main():
    open_data_emergency_medical_service = OpenDataEmergencyMedicalService(
        params=""
    )
    open_data_emergency_medical_service.process()


if __name__ == '__main__':
    main()
