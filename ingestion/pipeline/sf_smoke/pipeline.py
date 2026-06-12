import dlt
from vd_fabric_dlt_utils import setup_environment, finalize

from sources.salesforce import salesforce_source

setup_environment()

pipeline = dlt.pipeline(
    pipeline_name="sf_smoke_fab",
    destination="filesystem",
    dataset_name="src_ss_salesforce",
)

source = salesforce_source().with_resources("sf_user", "contact")
try:
    load_info = pipeline.run(source, table_format="delta")
except Exception as exc:
    finalize(pipeline, error_message=str(exc))
    raise

print(load_info)
print("audit:", finalize(pipeline))
