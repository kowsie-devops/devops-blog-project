FROM python:3.11-slim
WORKDIR /app
COPY app/ ./app/
RUN pip install --no-cache-dir -r app/requirements.txt
ENV FLASK_APP=app/app.py
ENV DB_PATH=/data/blog.db
RUN mkdir -p /data
EXPOSE 5000
CMD ["python","app/app.py"]
