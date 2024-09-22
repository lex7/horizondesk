class RequestIssue:
    type_mapping = {
        "Электрика": 1,
        "Инструменты": 2,
        "Санитарно-бытовые условия": 3,
        "Безопасность труда": 4,
        "Документооборот": 5
    }

    def __init__(self, type_name, description):
        self.type_name = type_name
        self.description = description
        self.request_type = self.type_mapping.get(type_name, 0)
        issue1 = RequestIssue("Электрика", "Проблема с проводкой")
        print(f'Type Name: {issue1.type_name}, '
              f'Request Type: {issue1.request_type}, '
              f'Description: {issue1.description}')

if __name__ == '__main__':
    RequestIssue(type_name="Электрика", description="cветит")