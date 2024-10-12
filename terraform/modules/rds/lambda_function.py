import pymysql
import os

def lambda_handler(event, context):
    # Database connection details
    connection = pymysql.connect(
        host=os.getenv('RDS_HOSTNAME'),
        user=os.getenv('RDS_USERNAME'),
        password=os.getenv('RDS_PASSWORD'),
        database=os.getenv('RDS_DB_NAME'),
        cursorclass=pymysql.cursors.DictCursor
    )

    try:
        with connection.cursor() as cursor:
            # Create the hibernate_sequence table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS hibernate_sequence (
                    next_val BIGINT NOT NULL
                );
            """)

            # Insert into the hibernate_sequence table
            cursor.execute("""
                INSERT INTO hibernate_sequence (next_val)
                VALUES (1)
                ON DUPLICATE KEY UPDATE next_val = next_val;
            """)

            # Create the manager table
            cursor.execute("""
               CREATE TABLE IF NOT EXISTS manager (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(255) UNIQUE,
                    password VARCHAR(255),
                    roles VARCHAR(255)
                );
            """)

            # Modify the roles column
            cursor.execute("""
                ALTER TABLE manager
                MODIFY COLUMN roles VARCHAR(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
            """)

            # Create the employee table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS employee (
                    id BIGINT AUTO_INCREMENT PRIMARY KEY,
                    first_name VARCHAR(255) NOT NULL,
                    last_name VARCHAR(255) NOT NULL,
                    description TEXT,
                    manager_id BIGINT,
                    CONSTRAINT FK_manager FOREIGN KEY (manager_id) REFERENCES manager(id)
                );
            """)

            # Grant privileges (consider running this separately)
            cursor.execute("""
                GRANT ALL PRIVILEGES ON mydb.* TO 'greg'@'%';
            """)

            # Flush privileges
            cursor.execute("FLUSH PRIVILEGES;")

            # Commit the transaction
            connection.commit()

    finally:
        connection.close()

    return {
        'statusCode': 200,
        'body': 'SQL scripts executed successfully'
    }

