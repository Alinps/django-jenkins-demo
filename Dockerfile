FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV DJANGO_SETTINGS_MODULE=simple_django_app.settings

EXPOSE 8000

CMD ["gunicorn", "simple_django_app.wsgi:application", "--bind", "0.0.0.0:8000"]
