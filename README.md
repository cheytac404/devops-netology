# devops-netology
Будут игнорироваться следующие файлы:
Директории .terraform\
Локальные директории с именем .terraform
Все файлы, начинающиеся с *.tfstate
Файлы, содержащие .tfstate. в названии
Файлы crash.log.
Файлы с именами вида crash.любой_текст.log
Все файлы с расширением .tfvars или .tfvars.json
Файлы override.tf, override.tf.json.
Файлы, заканчивающиеся на _override.tf или _override.tf.json
Файл .terraform.tfstate.lock.info.
Файлы .terraformrc или terraform.rc.
