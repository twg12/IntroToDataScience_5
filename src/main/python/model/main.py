from data_pipeline.open_data_emergency_medical_service.core import OpenDataEmergencyMedicalService


def main():
    open_data_emergency_medical_service = OpenDataEmergencyMedicalService(
        params=""
    )
    open_data_emergency_medical_service.process()


if __name__ == '__main__':
    main()


# 데이터 불러와서 어떠한 과정을 처리하기 -> 데이터를 인코딩(추출하기) ( 인코딩할 데이터 불러와) -> 모델에 넣고 돌리기 ( 인코딩할 파일 이름 )
