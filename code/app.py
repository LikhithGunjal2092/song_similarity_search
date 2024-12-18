from flask import Flask, jsonify, request, render_template
import snowflake.connector

app = Flask(__name__)

# Snowflake connection details
SNOWFLAKE_CONFIG = {
    'user': 'snowflakeadmin',
    'password': 'Admin@1234',
    'account': 'qqb66605.us-east-1',
    'warehouse': 'COMPUTE_WH',
    'database': 'SPOTIFY',
    'schema': 'ANALYTICS'
}

# Function to create a Snowflake connection
def get_snowflake_connection():
    return snowflake.connector.connect(
        user=SNOWFLAKE_CONFIG['user'],
        password=SNOWFLAKE_CONFIG['password'],
        account=SNOWFLAKE_CONFIG['account'],
        warehouse=SNOWFLAKE_CONFIG['warehouse'],
        database=SNOWFLAKE_CONFIG['database'],
        schema=SNOWFLAKE_CONFIG['schema']
    )


@app.route('/')
def index():
    return render_template('index.html')

# Route to execute a query
@app.route('/find_song', methods=['POST'])
def find_song():
    song_name = request.form.get('song_name')
    if not song_name:
        return jsonify({"error": "Song name is required"}), 400

    escaped_song_name = song_name.replace("'", "''")
    query = f"SELECT * FROM TABLE(spotify.staging.find_similar_song('%{escaped_song_name}%'))"

    try:
        conn = get_snowflake_connection()
        cursor = conn.cursor()
        cursor.execute(query)
        result = cursor.fetchall()

        # Fetch column names
        column_names = [desc[0] for desc in cursor.description]

        # Format the result as a list of dictionaries
        data = [dict(zip(column_names, row)) for row in result]

        return render_template('results.html', data=data)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()
        conn.close()

if __name__ == '__main__':
    app.run(debug=True)