FROM python:3.11-slim

RUN pip install pipenv

WORKDIR /app

COPY ["deployment/flask/Pipfile", "deployment/flask/Pipfile.lock", "./"]

RUN pipenv install --deploy --system

RUN mkdir -p ./models
COPY ["deployment/flask/predict.py", "./"]
COPY ["models/best_model_convnext_tiny_bs8_lr0.001_acc0.7295_20260128_213109.pt", "models/"]

EXPOSE 9696

CMD ["gunicorn", "--bind=0.0.0.0:9696", "predict:app"]

# docker build -t coffee-defect-api -f deployment/flask/Dockerfile .