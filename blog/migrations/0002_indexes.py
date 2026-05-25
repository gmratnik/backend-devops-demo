from django.contrib.postgres.operations import AddIndexConcurrently
from django.db import migrations, models


class Migration(migrations.Migration):
    atomic = False

    dependencies = [("blog", "0001_initial")]

    operations = [
        AddIndexConcurrently(
            model_name="Post",
            index=models.Index(fields=["-created_at"], name="post_created_at_idx"),
        ),
        AddIndexConcurrently(
            model_name="Comment",
            index=models.Index(fields=["created_at"], name="comment_created_at_idx"),
        ),
    ]
