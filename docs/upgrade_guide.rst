Upgrade Guide
=============

How to bump **Autoware** and **Zenoh**. Versions are pinned in many places, so follow the checklists below.

Where versions are pinned
-------------------------

**Autoware** -- the image tag and ``AUTOWARE_VERSION``:

* ``container/Dockerfile_autoware`` -- base image tag.
* ``container/Dockerfile_carla_bridge`` -- base image tag.
* ``container/run-autoware-docker-src.sh`` -- image tag and ``AUTOWARE_VERSION``.
* ``container/run-autoware-docker.sh``, ``container/run-bridge-docker.sh`` -- image tag.
* ``docs/index.rst`` -- the ``Version`` block.

.. warning::

   The Autoware tag **format changes between releases** -- ``...cuda-1.7.1-jazzy-amd64`` became ``...cuda-jazzy-1.8.0`` at 1.8.0. Confirm the real tag on the `container registry <https://github.com/autowarefoundation/autoware/pkgs/container/autoware>`_.

**Zenoh** -- align every version string so they all match, then update each place below:

* ``container/Dockerfile_autoware`` -- ``eclipse-zenoh==<version>``, installed with pip ``--break-system-packages`` into the ROS 2 system Python rather than uv.
* ``external/zenoh_autoware_v2x/pyproject.toml`` -- ``eclipse-zenoh==<version>``, uv-managed and must match the Dockerfile version.
* ``external/zenoh_carla_bridge/Cargo.toml`` -- ``zenoh = "<version>"``.
* ``external/zenoh-plugin-ros2dds`` -- the upstream **eclipse-zenoh** plugin, not evshary's; check out the matching release tag and do not edit it.
* ``docs/index.rst`` -- the ``Version`` block.
* **FMS** -- `evshary/zenoh_autoware_fms <https://github.com/evshary/zenoh_autoware_fms>`_ is an external repo, not a submodule. In its ``pyproject.toml``:

  * match ``eclipse-zenoh==<version>``;
  * update the ``zenoh-ros-type`` git dep.

The ``zenoh_*`` submodules are evshary's. PR the source to evshary, wait for it to merge, then bump the submodule pointer.

**Not version-coupled** -- not tied to the Autoware/Zenoh bump:

* ``zenoh-ros-type`` -- serialised ROS message types, in two evshary repos. Only if a type is missing, PR it, then update the dependency:

  * Python `zenoh-ros-type-python <https://github.com/evshary/zenoh-ros-type-python>`_ is a git dep in ``zenoh_autoware_v2x/pyproject.toml``; bump it and run ``uv lock``.
  * Rust `zenoh-ros-type <https://github.com/evshary/zenoh-ros-type>`_ is a crates.io dep in ``zenoh_carla_bridge/Cargo.toml``; ask evshary for a release, then bump the version.

* **CARLA version** -- follows CARLA and is independent of this bump:

  * Python ``carla==<version>`` in ``zenoh_autoware_v2x/pyproject.toml`` and ``zenoh_carla_bridge/carla_agent/pyproject.toml``.
  * Rust ``carla = "<version>"`` in ``zenoh_carla_bridge/Cargo.toml`` uses the `carla-rust <https://github.com/jerry73204/carla-rust>`_ bindings. Its version is not the simulator version, so check that a release supports the target CARLA.
  * Docs version strings in ``docs/index.rst``, ``docs/prerequisites.rst``, and ``docs/scenarios/fms.rst``.

* ``external/zenoh_autoware_v2x/pyproject.toml`` -- confirm ``python >= 3.12``, ``numpy < 2``, and ``pygame`` still fit the base image.
* ``src/autoware_manual_control`` -- leave it unless a message or topic rename affects it.

Common issues
-------------

1. **Model URLs/versions** -- ``script/setup/download_models.sh``, ``build_models.sh``. Compare against `Autoware's artifact list <https://github.com/autowarefoundation/autoware/blob/main/ansible/roles/artifacts/tasks/main.yaml>`_ at the target tag and update any changed model.

2. **Topic renames break key expressions** -- ``config/zenoh-bridge-ros2dds-conf.json5`` and the router ingress/egress in ``config/RMW_ZENOH_ROUTER_V*.json5``.

3. **Base-image workarounds in** ``env.sh`` -- check whether the new image already does it; ``ip link set lo multicast on`` was dropped at 1.8.0, for instance.

4. **New apt packages** -- ``container/Dockerfile_autoware``. A new base image may lack packages such as ``xacro``, ``topic-tools``, or ``rviz2``; the symptom is a node or package missing at launch.

Procedure
---------

1. Confirm the target **tag format** and the **compatible Zenoh version** from the rmw_zenoh and zenoh-plugin-ros2dds release notes.
2. Bump all three Zenoh submodules and align every version string.
3. Update every file under `Where versions are pinned`_.
4. Rebuild, run, then walk the checklist.

Templates: search the git log for ``Bump`` -- Zenoh-only, Autoware-only, and combined bumps are all there.

Post-upgrade checklist
----------------------

* **Perception** -- models downloaded, detections appear.
* **Topics flow both ends** -- key expressions match the renamed topics.
* **No stale workarounds** in ``env.sh``.
