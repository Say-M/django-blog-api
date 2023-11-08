from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.shortcuts import render
from .utils import database
import json

# Create your views here.

@api_view(['GET', 'POST'])
def UsersHandler(request):
    if request.method == "GET":
        try: 
            page = request.GET.get("page", 1)
            limit = request.GET.get("limit", 10)

            database.cur.execute("""
                SELECT get_users(%s, %s);
            """, (page, limit))

            result = json.loads(json.dumps(database.cur.fetchone()[0]))
            
            database.conn.commit()

            return Response(
                {
                    "massage": result["status"] == "failed" and "User retrieval failed" or "User retrieved successfully",
                    "data": result
                },
                status = result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )


        except (Exception, database.Error) as error:
            database.conn.commit()

            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status = status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "POST":
        try:
            body = json.dumps(json.loads(request.body))

            database.cur.execute("""
                SELECT create_user(%s);
            """, (body,))

            result = json.loads(json.dumps(database.cur.fetchone()[0]))

            database.conn.commit()
            
            return Response(
                {
                    "massage": result["status"] == "failed" and "User creation failed" or "User created successfully",
                    "data": result
                },
                status = result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_201_CREATED
            )
        except (Exception, database.Error) as error:
            database.conn.commit()

            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status = status.HTTP_500_INTERNAL_SERVER_ERROR
            )


@api_view(['GET', 'PATCH', 'DELETE'])
def UserHandler(request, id):
    if request.method == "GET":
        try:
            database.cur.execute("""
                SELECT get_user(%s);
            """, (id,))

            result = json.loads(json.dumps(database.cur.fetchone()[0]))

            database.conn.commit()

            return Response(
                {
                    "massage": result["status"] == "failed" and "User retrieval failed" or "User retrieved successfully",
                    "data": result
                },
                status = result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )
            
        except (Exception, database.Error) as error:
            database.conn.commit()

            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status = status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "PATCH":
        try:
            body = json.dumps(json.loads(request.body))

            database.cur.execute("""
                SELECT update_user(%s, %s);
            """, (id, body))

            result = json.loads(json.dumps(database.cur.fetchone()[0]))

            database.conn.commit()

            return Response(
                {
                    "massage": result["status"] == "failed" and "User update failed" or "User updated successfully",
                    "data": result
                },
                status = result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )
            
        except (Exception, database.Error) as error:
            database.conn.commit()

            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status = status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    elif request.method == "DELETE":
        try:
            database.cur.execute("""
                SELECT delete_user(%s);
            """, (id,))

            result = json.loads(json.dumps(database.cur.fetchone()[0]))

            database.conn.commit()

            return Response(
                {
                    "massage": result["status"] == "failed" and "User deletion failed" or "User deleted successfully",
                    "data": result
                },
                status = result["status"] == "failed" and status.HTTP_400_BAD_REQUEST or status.HTTP_200_OK
            )
            
        except (Exception, database.Error) as error:
            database.conn.commit()

            print(f"Error while interacting with the database:\n{error}")
            return Response(
                {"message": f"Error while interacting with the database:\n{error}"},
                status = status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    else:
        return Response(
            {"message": f"Invalid request method {request.method}"},
            status = status.HTTP_405_METHOD_NOT_ALLOWED
        )